class MiqExpression::Visitors::ArelVisitor
  attr_reader :timezone, :escape, :case_sensitive

  def initialize(timezone = "UTC")
    @timezone = timezone
    @escape = nil
    @case_sensitive = true
  end

  def visit(subject)
    method_name = :"visit_#{subject.class.name.split("::").last.underscore}"
    public_send(method_name, subject)
  end

  def visit_equal(subject)
    subject.arel_attribute.eq(subject.value) if subject.arel_attribute
  end

  def visit_less_than(subject)
    subject.arel_attribute.lt(subject.value)
  end

  def visit_less_than_or_equal(subject)
    subject.arel_attribute.lteq(subject.value)
  end

  def visit_greater_than(subject)
    subject.arel_attribute.gt(subject.value)
  end

  def visit_greater_than_or_equal(subject)
    subject.arel_attribute.gteq(subject.value)
  end

  def visit_is_empty(subject)
    arel = subject.arel_attribute.eq(nil)
    arel = arel.or(subject.arel_attribute.eq("")) if subject.target.string?
    arel
  end

  def visit_is_not_empty(subject)
    arel = subject.arel_attribute.not_eq(nil)
    arel = arel.and(subject.arel_attribute.not_eq("")) if subject.target.string?
    arel
  end

  def visit_not_equal(subject)
    subject.arel_attribute.not_eq(subject.value)
  end

  def visit_like(subject)
    subject.arel_attribute.matches("%#{subject.value}%", escape, case_sensitive)
  end

  def visit_not_like(subject)
    subject.arel_attribute.does_not_match("%#{subject.value}%", escape, case_sensitive)
  end

  def visit_starts_with(subject)
    subject.arel_attribute.matches("#{subject.value}%", escape, case_sensitive)
  end

  def visit_contains(subject)
    case subject.target
    when MiqExpression::Tag
      ids = subject.target.model.find_tagged_with(:any => subject.value, :ns => subject.target.namespace).pluck(:id)
      subject.target.model.arel_attribute(:id).in(ids)
    when MiqExpression::Field
      raise unless subject.target.associations.one?
      reflection = subject.target.reflections.first
      return nil unless subject.arel_attribute
      arel = subject.arel_attribute.eq(subject.value)
      if reflection.scope
        arel = arel.and(Arel::Nodes::SqlLiteral.new(extract_where_values(reflection.klass, reflection.scope)))
      end
      subject.target.model.arel_attribute(:id).in(
        subject.target.arel_table.where(arel).project(subject.target.arel_table[reflection.foreign_key]).distinct
      )
    end
  end

  def visit_ends_with(subject)
    subject.arel_attribute.matches("%#{subject.value}", escape, case_sensitive)
  end

  def visit_is_not_null(subject)
    subject.arel_attribute.not_eq(nil)
  end

  def visit_is_null(subject)
    subject.arel_attribute.eq(nil)
  end

  def visit_is(subject)
    if !subject.target.date? || MiqExpressionRelativeDatetime.relative?(subject.value)
      subject.arel_attribute.between(subject.start_value(timezone)..subject.end_value(timezone))
    else
      subject.arel_attribute.eq(subject.start_value(timezone))
    end
  end

  def visit_from(subject)
    subject.arel_attribute.between(subject.start_value(timezone)..subject.end_value(timezone))
  end

  def visit_not(subject)
    Arel::Nodes::Not.new(subject.sub_expression.accept(self))
  end

  def visit_or(subject)
    return nil unless subject.sub_expressions.all?(&:sql?)
    first, *rest = subject.sub_expressions
    rest.inject(first.accept(self)) { |arel, sub_expression| arel.or(sub_expression.accept(self)) }
  end

  def visit_and(subject)
    return nil if subject.sub_expressions.none?(&:sql?)
    first, *rest = subject.sub_expressions.select(&:sql?)
    rest.inject(first.accept(self)) { |arel, sub_expression| arel.and(sub_expression.accept(self)) }
  end

  def visit_before(subject)
    subject.arel_attribute.lt(MiqExpression::RelativeDatetime.normalize(subject.value, timezone, "beginning", subject.target.date?))
  end

  def visit_after(subject)
    subject.arel_attribute.gt(MiqExpression::RelativeDatetime.normalize(subject.value, timezone, "end", subject.target.date?))
  end

  private

  class WhereExtractionVisitor < Arel::Visitors::PostgreSQL
    def visit_Arel_Nodes_SelectStatement(o, collector)
      collector = o.cores.inject(collector) do |c, x|
        visit_Arel_Nodes_SelectCore(x, c)
      end
    end

    def visit_Arel_Nodes_SelectCore(o, collector)
      unless o.wheres.empty?
        len = o.wheres.length - 1
        o.wheres.each_with_index do |x, i|
          collector = visit(x, collector)
          collector << AND unless len == i
        end
      end

      collector
    end
  end

  def extract_where_values(klass, scope)
    relation = ActiveRecord::Relation.new klass, klass.arel_table, klass.predicate_builder
    relation = relation.instance_eval(&scope)

    begin
      # This is basically ActiveRecord::Relation#to_sql, only using our
      # custom visitor instance

      connection = klass.connection
      visitor    = WhereExtractionVisitor.new connection

      arel  = relation.arel
      binds = relation.bound_attributes
      binds = connection.prepare_binds_for_database(binds)
      binds.map! { |value| connection.quote(value) }
      collect = visitor.accept(arel.ast, Arel::Collectors::Bind.new)
      collect.substitute_binds(binds).join
    end
  end
end
