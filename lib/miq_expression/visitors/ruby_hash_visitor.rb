class MiqExpression::Visitors::RubyHashVisitor
  attr_reader :timezone

  def initialize(timezone = "UTC")
    @timezone = timezone
  end

  def visit(subject)
    method_name = :"visit_#{subject.class.name.split("::").last.underscore}"
    public_send(method_name, subject)
  end


  def visit_equal(subject)
    # maybe not column - needs to be association.column
    "<value type=#{subject.column_type}>#{subject.column}</value> == #{subject.value}"
  end

  def visit_less_than(subject)
    "<value type=#{subject.column_type}>#{subject.column}</value> < #{subject.value}"
  end

  def visit_less_than_or_equal(subject)
    "<value type=#{subject.column_type}>#{subject.column}</value> <= #{subject.value}"
  end

  def visit_greater_than(subject)
    "<value type=#{subject.column_type}>#{subject.column}</value> > #{subject.value}"
  end

  def visit_greater_than_or_equal(subject)
    "<value type=#{subject.column_type}>#{subject.column}</value> >= #{subject.value}"
  end

  def visit_is_empty(subject)
    "<value type=#{subject.column_type}>#{subject.column}</value> == \"\""
  end

  def visit_is_not_empty(subject)
    "<value type=#{subject.column_type}>#{subject.column}</value> != \"\""
  end

  def visit_not_equal(subject)
    "<value type=#{subject.column_type}>#{subject.column}</value> != #{subject.value}"
  end

  def visit_like(subject)
    operands[1] = "/" + re_escape(operands[1].to_s) + "/"
    "<value type=#{subject.column_type}>#{subject.column}</value> =~ #{subject.value}"
  end

  def visit_not_like(subject)
    operands[1] = "/" + re_escape(operands[1].to_s) + "/"
    "!(<value type=#{subject.column_type}>#{subject.column}</value> =~ #{subject.value})"
  end

  def visit_starts_with(subject)
    operands[1] = "/^" + re_escape(operands[1].to_s) + "/"
    "<value type=#{subject.column_type}>#{subject.column}</value> =~ #{subject.value}"
  end

  def visit_contains(subject)
    # This is only for supporting reporting "display filters"
    # In the report object the tag value is actually the description and not the raw tag name.
    # So we have to trick it by replacing the value with the description.
    description = MiqExpression.get_entry_details(exp[operator]["tag"]).inject("") do |s, t|
      break(t.first) if t.last == exp[operator]["value"]
      s
    end
    val = exp[operator]["tag"].split(".").last.split("-").join(".")
    fld = "<value type=string>#{val}</value>"
    [fld, quote(description, "string")]
    operands.join(" CONTAINS ")
  end

  def visit_ends_with(subject)
    operands[1] = "/" + re_escape(operands[1].to_s) + "$/"
    "<value type=#{subject.column_type}>#{subject.column}</value> =~ #{subject.value}"
  end

  def visit_is_not_null(subject)
    "<value type=#{subject.column_type}>#{subject.column}</value> != #{subject.value}"
  end

  def visit_is_null(subject)
    "<value type=#{subject.column_type}>#{subject.column}</value> == #{subject.value}"
  end

  def visit_is(subject)
    if col_type == :date && !RelativeDatetime.relative?(value)
      ruby_for_date_compare(col_ruby, col_type, tz, "==", value)
    else
      ruby_for_date_compare(col_ruby, col_type, tz, ">=", value, "<=", value)
    end

    "<value type=#{subject.column_type}>#{subject.column}</value> #{operator} #{subject.value}"
  end

  def visit_not(subject)
    "!" + "(" + _to_ruby(exp[operator], context_type, tz) + ")"
  end

  def visit_or(subject)
    "(" + exp[operator].collect { |operand| _to_ruby(operand, context_type, tz) }.join(" or ") + ")"
  end

  def visit_and(subject)
    "(" + exp[operator].collect { |operand| _to_ruby(operand, context_type, tz) }.join(" and ") + ")"
  end

  def visit_before(subject)
    "<value type=#{subject.column_type}>#{subject.column}</value> < #{subject.value}"
  end

  def visit_after(subject)
    "<value type=#{subject.column_type}>#{subject.column}</value> > #{subject.value}"
  end

  def visit_regular_expression_matches(subject)
    "<value type=#{subject.column_type}>#{subject.column}</value> =~ #{subject.value}"
  end

  def visit_regular_expression_does_not_match(subject)
    "<value type=#{subject.column_type}>#{subject.column}</value> !~ #{subject.value}"
  end

  def visit_includes_any(subject)
    "(#{subject.value} - <value type=#{subject.column_type}>#{subject.column}</value>) != #{subject.value}"
  end

  def visit_includes_all(subject)
    "(<value type=#{subject.column_type}>#{subject.column}</value> & #{subject.value}) == #{subject.value}"
  end

  def visit_includes_only(subject)
    "(<value type=#{subject.column_type}>#{subject.column}</value> - #{subject.value}) == []"
  end

  def visit_limited_to(subject)
    "(<value type=#{subject.column_type}>#{subject.column}</value> - #{subject.value}) == []"
  end

  def visit_from(subject)
    ruby_for_date_compare(col_ruby, col_type, tz, ">=", start_val, "<=", end_val)
    "<value type=#{subject.column_type}>#{subject.value}</value>"
  end
end
