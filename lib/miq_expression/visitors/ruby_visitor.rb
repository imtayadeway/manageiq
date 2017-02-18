class MiqExpression::Visitors::RubyVisitor
  attr_reader :timezone

  def initialize(timezone = "UTC")
    @timezone = timezone
  end

  def visit(subject)
    method_name = :"visit_#{subject.class.name.split("::").last.underscore}"
    public_send(method_name, subject)
  end

  def visit_equal(subject)
    case subject.target
    when MiqExpression::Field
      "<value ref=#{subject.ref}, type=#{subject.column_type}>#{subject.to_tag}</value> == #{subject.ruby_value}"
    when MiqExpression::Count
      "<count ref=#{subject.ref}>#{subject.to_tag}</count> == #{subject.ruby_value}"
    when MiqExpression::Regkey
      "<registry>#{subject.target.regkey} : #{subject.target.regval}</registry> == #{subject.ruby_value}"
    end
  end

  def visit_less_than(subject)
    case subject.target
    when MiqExpression::Field
      "<value ref=#{subject.ref}, type=#{subject.column_type}>#{subject.to_tag}</value> < #{subject.ruby_value}"
    when MiqExpression::Count
      "<count ref=#{subject.ref}>#{subject.to_tag}</count> < #{subject.ruby_value}"
    when MiqExpression::Regkey
      "<registry>#{subject.target.regkey} : #{subject.target.regval}</registry> < #{subject.ruby_value}"
    end
  end

  def visit_less_than_or_equal(subject)
    case subject.target
    when MiqExpression::Field
      "<value ref=#{subject.ref}, type=#{subject.column_type}>#{subject.to_tag}</value> <= #{subject.ruby_value}"
    when MiqExpression::Count
      "<count ref=#{subject.ref}>#{subject.to_tag}</count> <= #{subject.ruby_value}"
    when MiqExpression::Regkey
      "<registry>#{subject.target.regkey} : #{subject.target.regval}</registry> <= #{subject.ruby_value}"
    end
  end

  def visit_greater_than(subject)
    case subject.target
    when MiqExpression::Field
      "<value ref=#{subject.ref}, type=#{subject.column_type}>#{subject.to_tag}</value> > #{subject.ruby_value}"
    when MiqExpression::Count
      "<count ref=#{subject.ref}>#{subject.to_tag}</count> > #{subject.ruby_value}"
    when MiqExpression::Regkey
      "<registry>#{subject.target.regkey} : #{subject.target.regval}</registry> > #{subject.ruby_value}"
    end
  end

  def visit_greater_than_or_equal(subject)
    case subject.target
    when MiqExpression::Field
      "<value ref=#{subject.ref}, type=#{subject.column_type}>#{subject.to_tag}</value> >= #{subject.ruby_value}"
    when MiqExpression::Count
      "<count ref=#{subject.ref}>#{subject.to_tag}</count> >= #{subject.ruby_value}"
    when MiqExpression::Regkey
      "<registry>#{subject.target.regkey} : #{subject.target.regval}</registry> >= #{subject.ruby_value}"
    end
  end

  def visit_is_empty(subject)
    case subject.target
    when MiqExpression::Field
      "<value ref=#{subject.ref}, type=#{subject.column_type}>#{subject.to_tag}</value> == #{subject.ruby_value}"
    when MiqExpression::Count
      "<count ref=#{subject.ref}>#{subject.to_tag}</count> == #{subject.ruby_value}"
    when MiqExpression::Regkey
      "<registry>#{subject.target.regkey} : #{subject.target.regval}</registry> == #{subject.ruby_value}"
    end
  end

  def visit_is_not_empty(subject)
    case subject.target
    when MiqExpression::Field
      "<value ref=#{subject.ref}, type=#{subject.column_type}>#{subject.to_tag}</value> != #{subject.ruby_value}"
    when MiqExpression::Count
      "<count ref=#{subject.ref}>#{subject.to_tag}</count> != #{subject.ruby_value}"
    when MiqExpression::Regkey
      "<registry>#{subject.target.regkey} : #{subject.target.regval}</registry> != #{subject.ruby_value}"
    end
  end

  def visit_not_equal(subject)
    case subject.target
    when MiqExpression::Field
      "<value ref=#{subject.ref}, type=#{subject.column_type}>#{subject.to_tag}</value> != #{subject.ruby_value}"
    when MiqExpression::Count
      "<count ref=#{subject.ref}>#{subject.to_tag}</count> != #{subject.ruby_value}"
    when MiqExpression::Regkey
      "<registry>#{subject.target.regkey} : #{subject.target.regval}</registry> != #{subject.ruby_value}"
    end
  end

  def visit_like(subject)
    value = "/" + re_escape(subject.value) + "/"
    case subject.target
    when MiqExpression::Field
      "<value ref=#{subject.ref}, type=#{subject.column_type}>#{subject.to_tag}</value> =~ #{value}"
    when MiqExpression::Count
      "<count ref=#{subject.ref}>#{subject.to_tag}</count> =~ #{value}"
    when MiqExpression::Regkey
      "<registry>#{subject.target.regkey} : #{subject.target.regval}</registry> =~ #{value}"
    end
  end

  def visit_not_like(subject)
    value = "/" + re_escape(subject.value) + "/"
    case subject.target
    when MiqExpression::Field
      "!(<value ref=#{subject.ref}, type=#{subject.column_type}>#{subject.to_tag}</value> =~ #{value})"
    when MiqExpression::Count
      "!(<count ref=#{subject.ref}>#{subject.to_tag}</count> =~ #{value})"
    when MiqExpression::Regkey
      "!(<registry>#{subject.target.regkey} : #{subject.target.regval}</registry> =~ #{value})"
    end
  end

  def visit_starts_with(subject)
    value = "/^" + re_escape(subject.value) + "/"
    case subject.target
    when MiqExpression::Field
      "<value ref=#{subject.ref}, type=#{subject.column_type}>#{subject.to_tag}</value> =~ #{value}"
    when MiqExpression::Count
      "<count ref=#{subject.ref}>#{subject.to_tag}</count> =~ #{value}"
    when MiqExpression::Regkey
      "<registry>#{subject.target.regkey} : #{subject.target.regval}</registry> =~ #{value}"
    end
  end

  def visit_contains(subject)
    "<exist ref=#{subject.ref}>#{subject.ruby_value}</exist>"
  end

  def visit_ends_with(subject)
    value = "/" + re_escape(subject.value) + "$/"
    case subject.target
    when MiqExpression::Field
      "<value ref=#{subject.ref}, type=#{subject.column_type}>#{subject.to_tag}</value> =~ #{value}"
    when MiqExpression::Count
      "<count ref=#{subject.ref}>#{subject.to_tag}</count> =~ #{value}"
    when MiqExpression::Regkey
      "<registry>#{subject.target.regkey} : #{subject.target.regval}</registry> =~ #{value}"
    end
  end

  def visit_is_not_null(subject)
    case subject.target
    when MiqExpression::Field
      "<value ref=#{subject.ref}, type=#{subject.column_type}>#{subject.to_tag}</value> != #{subject.ruby_value}"
    when MiqExpression::Count
      "<count ref=#{subject.ref}>#{subject.to_tag}</count> != #{subject.ruby_value}"
    when MiqExpression::Regkey
      "<registry>#{subject.target.regkey} : #{subject.target.regval}</registry> != #{subject.ruby_value}"
    end
  end

  def visit_is_null(subject)
    case subject.target
    when MiqExpression::Field
      "<value ref=#{subject.ref}, type=#{subject.column_type}>#{subject.to_tag}</value> == #{subject.ruby_value}"
    when MiqExpression::Count
      "<count ref=#{subject.ref}>#{subject.to_tag}</count> == #{subject.ruby_value}"
    when MiqExpression::Regkey
      "<registry>#{subject.target.regkey} : #{subject.target.regval}</registry> == #{subject.ruby_value}"
    end
  end

  def visit_is(subject)
    start_val = MiqExpression::RelativeDatetime.normalize(subject.value, timezone, "beginning", subject.target.date?).iso8601
    end_val = MiqExpression::RelativeDatetime.normalize(subject.value, timezone, "end", subject.target.date?).iso8601
    "val=<value ref=#{subject.ref}, type=#{subject.column_type}>#{subject.to_tag}</value>; !val.nil? && val.to_time >= '#{start_val}'.to_time(:utc) && val.to_time <= '#{end_val}'.to_time(:utc)"
  end

  def visit_not(subject)
    "!(" + subject.sub_expression.accept(self) + ")"
  end

  def visit_or(subject)
    first, *rest = subject.sub_expressions
    "(" + rest.inject(first.accept(self)) { |ruby, sub_expression| "#{ruby} or #{sub_expression.accept(self)}"} + ")"
  end

  def visit_and(subject)
    first, *rest = subject.sub_expressions
    "(" + rest.inject(first.accept(self)) { |ruby, sub_expression| "#{ruby} and #{sub_expression.accept(self)}"} + ")"
  end

  def visit_before(subject)
    value = MiqExpression::RelativeDatetime.normalize(subject.value, timezone, "beginning", subject.target.date?).iso8601
    "val=<value ref=#{subject.ref}, type=#{subject.column_type}>#{subject.to_tag}</value>; !val.nil? && val.to_time < '#{value}'.to_time(:utc)"
  end

  def visit_after(subject)
    value = MiqExpression::RelativeDatetime.normalize(subject.value, timezone, "end", subject.target.date?).iso8601
    "val=<value ref=#{subject.ref}, type=#{subject.column_type}>#{subject.to_tag}</value>; !val.nil? && val.to_time > '#{value}'.to_time(:utc)"
  end

  def visit_regular_expression_matches(subject)
    case subject.target
    when MiqExpression::Field
      "<value ref=#{subject.ref}, type=#{subject.column_type}>#{subject.to_tag}</value> =~ #{subject.value}"
    when MiqExpression::Regkey
      "<registry>#{subject.target.regkey} : #{subject.target.regval}</registry> =~ #{subject.value}"
    end
  end

  def visit_regular_expression_does_not_match(subject)
    case subject.target
    when MiqExpression::Field
      "<value ref=#{subject.ref}, type=#{subject.column_type}>#{subject.to_tag}</value> !~ #{subject.vlaue}"
    when MiqExpression::Regkey
      "<registry>#{subject.target.regkey} : #{subject.target.regval}</registry> !~ #{subject.value}"
    end
  end

  def visit_key_exists(subject)
    "<registry key_exists=1, type=boolean>#{subject.target.regkey}</registry>  == 'true'"
  end

  def visit_value_exists(subject)
    "<registry value_exists=1, type=boolean>#{subject.target.regkey} : #{subject.target.regval}</registry>  == 'true'"
  end

  def visit_includes_any(subject)
    "(#{subject.ruby_value} - <value ref=#{subject.ref}, type=#{subject.column_type}>#{subject.to_tag}</value>) != #{subject.ruby_value}"
  end

  def visit_includes_all(subject)
    fld = "<value ref=#{subject.ref}, type=#{subject.column_type}>#{subject.to_tag}</value>"
    operands = [fld, subject.ruby_value]
    "(#{operands[0]} & #{operands[1]}) == #{operands[1]}"
  end

  def visit_includes_only(subject)
    fld = "<value ref=#{subject.ref}, type=#{subject.column_type}>#{subject.to_tag}</value>"
    operands = [fld, subject.ruby_value]
    "(#{operands[0]} - #{operands[1]}) == []"
  end

  def visit_limited_to(subject)
    fld = "<value ref=#{subject.ref}, type=#{subject.column_type}>#{subject.to_tag}</value>"
    operands = [fld, subject.ruby_value]
    "(#{operands[0]} - #{operands[1]}) == []"
  end

  def visit_find(subject)
    "<find><search>" + subject.search.accept(self) + "</search><check mode=#{subject.check.mode}>" + subject.check.accept(self) + "</check></find>"
  end

  def visit_from(subject)
    start_val, end_val = subject.value
    start_val = MiqExpression::RelativeDatetime.normalize(start_val, timezone, "beginning", subject.target.date?).iso8601
    end_val = MiqExpression::RelativeDatetime.normalize(end_val, timezone, "end", subject.target.date?).iso8601

    "val=<value ref=#{subject.ref}, type=#{subject.column_type}>#{subject.to_tag}</value>; !val.nil? && val.to_time >= '#{start_val}'.to_time(:utc) && val.to_time <= '#{end_val}'.to_time(:utc)"
  end

  def visit_search(subject)
    subject.sub_expression.accept(self)
  end

  def visit_checkall(subject)
    "<value ref=#{subject.sub_expression.ref}, type=string>#{subject.sub_expression.to_tag}</value> #{subject.sub_expression.ruby_operator} #{MiqExpression::Coercer.coerce(subject.sub_expression.value, :string)}"
  end

  def visit_checkany(subject)
    "<value ref=#{subject.sub_expression.ref}, type=string>#{subject.sub_expression.to_tag}</value> #{subject.sub_expression.ruby_operator} #{MiqExpression::Coercer.coerce(subject.sub_expression.value, :string)}"
  end

  def visit_checkcount(subject)
    "<count> #{subject.sub_expression.ruby_operator} #{MiqExpression::Coercer.coerce(subject.sub_expression.value, :integer)}"
  end

  private

  # TODO: update this to use the more nuanced
  # .sanitize_regular_expression after performing Regexp.escape. The
  # extra substitution is required because, although the result from
  # Regexp.escape is fine to pass to Regexp.new, it is not when eval'd
  # as we do:
  #
  # ```ruby
  # regexp_string = Regexp.escape("/") # => "/"
  # # ...
  # eval("/" + regexp_string + "/")
  # ```
  def re_escape(s)
    Regexp.escape(s).gsub(/\//, '\/')
  end
end
