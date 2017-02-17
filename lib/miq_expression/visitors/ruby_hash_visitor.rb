class MiqExpression::Visitors::RubyHashVisitor < MiqExpression::Visitors::RubyVisitor
  attr_reader :timezone

  def initialize(timezone = "UTC")
    @timezone = timezone
  end

  def visit(subject)
    method_name = :"visit_#{subject.class.name.split("::").last.underscore}"
    public_send(method_name, subject)
  end


  def visit_equal(subject)
    "<value type=#{subject.column_type}>#{subject.column}</value> == #{subject.ruby_value}"
  end

  def visit_less_than(subject)
    "<value type=#{subject.column_type}>#{subject.full_message_chain}</value> < #{subject.ruby_value}"
  end

  def visit_less_than_or_equal(subject)
    "<value type=#{subject.column_type}>#{subject.full_message_chain}</value> <= #{subject.ruby_value}"
  end

  def visit_greater_than(subject)
    "<value type=#{subject.column_type}>#{subject.full_message_chain}</value> > #{subject.ruby_value}"
  end

  def visit_greater_than_or_equal(subject)
    "<value type=#{subject.column_type}>#{subject.full_message_chain}</value> >= #{subject.ruby_value}"
  end

  def visit_is_empty(subject)
    "<value type=#{subject.column_type}>#{subject.full_message_chain}</value> == \"\""
  end

  def visit_is_not_empty(subject)
    "<value type=#{subject.column_type}>#{subject.full_message_chain}</value> != \"\""
  end

  def visit_not_equal(subject)
    "<value type=#{subject.column_type}>#{subject.full_message_chain}</value> != #{subject.ruby_value}"
  end

  def visit_like(subject)
    value = "/" + re_escape(subject.value) + "/"
    "<value type=#{subject.column_type}>#{subject.full_message_chain}</value> =~ #{value}"
  end

  def visit_not_like(subject)
    value = "/" + re_escape(subject.value) + "/"
    "!(<value type=#{subject.column_type}>#{subject.full_message_chain}</value> =~ #{value})"
  end

  def visit_starts_with(subject)
    value = "/^" + re_escape(subject.value) + "/"
    "<value type=#{subject.column_type}>#{subject.full_message_chain}</value> =~ #{value}"
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
    value = "/" + re_escape(subject.value) + "$/"
    "<value type=#{subject.column_type}>#{subject.full_message_chain}</value> =~ #{value}"
  end

  def visit_is_not_null(subject)
    "<value type=#{subject.column_type}>#{subject.full_message_chain}</value> != #{subject.ruby_value}"
  end

  def visit_is_null(subject)
    "<value type=#{subject.column_type}>#{subject.full_message_chain}</value> == #{subject.ruby_value}"
  end

  def visit_is(subject)
    start_val = MiqExpression::RelativeDatetime.normalize(subject.value, timezone, "beginning", subject.target.date?).iso8601
    end_val = MiqExpression::RelativeDatetime.normalize(subject.value, timezone, "end", subject.target.date?).iso8601
    "val=<value type=#{subject.column_type}>#{subject.full_message_chain}</value>; !val.nil? && val.to_time >= '#{start_val}'.to_time(:utc) && val.to_time <= '#{end_val}'.to_time(:utc)"
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
    value = MiqExpression::RelativeDatetime.normalize(subject.value, timezone, "beginning", subject.target.date?).iso8601
    "val=<value type=#{subject.column_type}>#{subject.full_message_chain}</value>; !val.nil? && val.to_time < '#{value}'.to_time(:utc)"
  end

  def visit_after(subject)
    value = MiqExpression::RelativeDatetime.normalize(subject.value, timezone, "end", subject.target.date?).iso8601
    "val=<value type=#{subject.column_type}>#{subject.full_message_chain}</value>; !val.nil? && val.to_time > '#{value}'.to_time(:utc) "
  end

  def visit_regular_expression_matches(subject)
    # If it looks like a regular expression, sanitize from forward
    # slashes and interpolation
    #
    # Regular expressions with a single option are also supported,
    # e.g. "/abc/i"
    #
    # Otherwise sanitize the whole string and add the delimiters
    #
    # TODO: support regexes with more than one option
    value = subject.value
    if value.starts_with?("/") && value.ends_with?("/")
      value[1..-2] = sanitize_regular_expression(value[1..-2])
    elsif value.starts_with?("/") && value[-2] == "/"
      value[1..-3] = sanitize_regular_expression(value[1..-3])
    else
      value = "/" + sanitize_regular_expression(value.to_s) + "/"
    end
    "<value type=#{subject.column_type}>#{subject.full_message_chain}</value> =~ #{value}"
  end

  def visit_regular_expression_does_not_match(subject)
# If it looks like a regular expression, sanitize from forward
    # slashes and interpolation
    #
    # Regular expressions with a single option are also supported,
    # e.g. "/abc/i"
    #
    # Otherwise sanitize the whole string and add the delimiters
    #
    # TODO: support regexes with more than one option
    value = subject.value
    if value.starts_with?("/") && value.ends_with?("/")
      value[1..-2] = sanitize_regular_expression(value[1..-2])
    elsif value.starts_with?("/") && value[-2] == "/"
      value[1..-3] = sanitize_regular_expression(value[1..-3])
    else
      value = "/" + sanitize_regular_expression(value.to_s) + "/"
    end
    "<value type=#{subject.column_type}>#{subject.full_message_chain}</value> !~ #{value}"
  end

  def visit_includes_any(subject)
    "(#{subject.ruby_value} - <value type=#{subject.column_type}>#{subject.full_message_chain}</value>) != #{subject.ruby_value}"
  end

  def visit_includes_all(subject)
    "(<value type=#{subject.column_type}>#{subject.full_message_chain}</value> & #{subject.ruby_value}) == #{subject.ruby_value}"
  end

  def visit_includes_only(subject)
    "(<value type=#{subject.column_type}>#{subject.full_message_chain}</value> - #{subject.ruby_value}) == []"
  end

  def visit_limited_to(subject)
    "(<value type=#{subject.column_type}>#{subject.full_message_chain}</value> - #{subject.ruby_value}) == []"
  end

  def visit_from(subject)
    start_val, end_val = subject.value
    start_val = MiqExpression::RelativeDatetime.normalize(start_val, timezone, "beginning", subject.target.date?).iso8601
    end_val = MiqExpression::RelativeDatetime.normalize(end_val, timezone, "end", subject.target.date?).iso8601
    "val=<value type=#{subject.column_type}>#{subject.full_message_chain}</value>; !val.nil? && val.to_time >= '#{start_val}'.to_time(:utc) && val.to_time <= '#{end_val}'.to_time(:utc)"
  end
end
