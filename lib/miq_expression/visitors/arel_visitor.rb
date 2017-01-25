class MiqExpression::Visitors::ArelVisitor
  attr_reader :timezone

  def initialize(timezone = "UTC")
    @timezone = timezone
  end

  def visit(subject)
    method_name = :"visit_#{subject.class.name.split("::").last.underscore}"
    public_send(method_name, subject)
  end

  def visit_equal(subject)
    subject.target.eq(subject.value)
  end

  def visit_less_than(subject)
    subject.target.lt(subject.value)
  end

  def visit_less_than_or_equal(subject)
    subject.target.lteq(subject.value)
  end

  def visit_greater_than(subject)
    subject.target.gt(subject.value)
  end

  def visit_greater_than_or_equal(subject)
    subject.target.gteq(subject.value)
  end

  def visit_is_empty(subject)
    arel = subject.target.eq(nil)
    arel = arel.or(subject.target.eq("")) if subject.target.string?
    arel
  end

  def visit_is_not_empty(subject)
    arel = subject.target.not_eq(nil)
    arel = arel.and(subject.target.not_eq("")) if subject.target.string?
    arel
  end

  def visit_not_equal(subject)
    subject.target.not_eq(subject.value)
  end

  def visit_like(subject)
    subject.target.matches("%#{subject.value}%")
  end

  def visit_not_like(subject)
    subject.target.does_not_match("%#{subject.value}%")
  end

  def visit_starts_with(subject)
    subject.target.matches("#{subject.value}%")
  end

  def visit_contains(subject)
    subject.target.contains(subject.value)
  end

  def visit_ends_with(subject)
    subject.target.matches("%#{subject.value}")
  end

  def visit_is_not_null(subject)
    subject.target.not_eq(nil)
  end

  def visit_is_null(subject)
    subject.target.eq(nil)
  end

  def visit_is(subject)
    if !subject.target.date? || MiqExpressionRelativeDatetime.relative?(subject.value)
      subject.target.between(subject.start_value(timezone)..subject.end_value(timezone))
    else
      subject.target.eq(subject.start_value(timezone))
    end
  end

  def visit_from(subject)
    subject.target.between(subject.start_value(timezone)..subject.end_value(timezone))
  end

  def visit_not(subject)
    Arel::Nodes::Not.new(subject.sub_expression.accept(self))
  end

  def visit_or(subject)
    first, *rest = subject.sub_expressions
    rest.inject(first.accept(self)) { |arel, sub_expression| arel.or(sub_expression.accept(self)) }
  end

  def visit_and(subject)
    first, *rest = subject.sub_expressions
    rest.inject(first.accept(self)) { |arel, sub_expression| arel.and(sub_expression.accept(self)) }
  end

  def visit_before(subject)
    subject.target.lt(MiqExpression::RelativeDatetime.normalize(subject.value, timezone, "beginning", subject.target.date?))
  end

  def visit_after(subject)
    subject.target.gt(MiqExpression::RelativeDatetime.normalize(subject.value, timezone, "end", subject.target.date?))
  end
end
