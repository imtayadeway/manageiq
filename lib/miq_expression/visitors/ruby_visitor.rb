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
    when MiqExpression::CountField
      "<count> == #{subject.ruby_value}"
    when MiqExpression::Count
      "<count ref=#{subject.ref}>#{subject.to_tag}</count> == #{subject.ruby_value}"
    when MiqExpression::Regkey
      "<registry>#{exp[operator]["regkey"].strip} : #{exp[operator]["regval"]}</registry> == #{subject.ruby_value}"
    end
  end

  def visit_less_than(subject)
    case subject.target
    when MiqExpression::Field
      "<value ref=#{subject.ref}, type=#{subject.column_type}>#{subject.to_tag}</value> < #{subject.ruby_value}"
    when MiqExpression::CountField
      "<count> < #{subject.ruby_value}"
    when MiqExpression::Count
      "<count ref=#{subject.ref}>#{subject.to_tag}</count> < #{subject.ruby_value}"
    when MiqExpression::Regkey
      "<registry>#{exp[operator]["regkey"].strip} : #{exp[operator]["regval"]}</registry> < #{subject.ruby_value}"
    end
  end

  def visit_less_than_or_equal(subject)
    case subject.target
    when MiqExpression::Field
      "<value ref=#{subject.ref}, type=#{subject.column_type}>#{subject.to_tag}</value> <= #{subject.ruby_value}"
    when MiqExpression::CountField
      "<count> <= #{subject.ruby_value}"
    when MiqExpression::Count
      "<count ref=#{subject.ref}>#{subject.to_tag}</count> <= #{subject.ruby_value}"
    when MiqExpression::Regkey
      "<registry>#{exp[operator]["regkey"].strip} : #{exp[operator]["regval"]}</registry> <= #{subject.ruby_value}"
    end
  end

  def visit_greater_than(subject)
    case subject.target
    when MiqExpression::Field
      "<value ref=#{subject.ref}, type=#{subject.column_type}>#{subject.to_tag}</value> > #{subject.ruby_value}"
    when MiqExpression::CountField
      "<count> > #{subject.ruby_value}"
    when MiqExpression::Count
      "<count ref=#{subject.ref}>#{subject.to_tag}</count> > #{subject.ruby_value}"
    when MiqExpression::Regkey
      "<registry>#{exp[operator]["regkey"].strip} : #{exp[operator]["regval"]}</registry> > #{subject.ruby_value}"
    end
  end

  def visit_greater_than_or_equal(subject)
    case subject.target
    when MiqExpression::Field
      "<value ref=#{subject.ref}, type=#{subject.column_type}>#{subject.to_tag}</value> >= #{subject.ruby_value}"
    when MiqExpression::CountField
      "<count> >= #{subject.ruby_value}"
    when MiqExpression::Count
      "<count ref=#{subject.ref}>#{subject.to_tag}</count> >= #{subject.ruby_value}"
    when MiqExpression::Regkey
      "<registry>#{exp[operator]["regkey"].strip} : #{exp[operator]["regval"]}</registry> >= #{subject.ruby_value}"
    end
  end

  def visit_is_empty(subject)
    case subject.target
    when MiqExpression::Field
      "<value ref=#{subject.ref}, type=#{subject.column_type}>#{subject.to_tag}</value> == #{subject.ruby_value}"
    when MiqExpression::CountField
      "<count> == #{subject.ruby_value}"
    when MiqExpression::Count
      "<count ref=#{subject.ref}>#{subject.to_tag}</count> == #{subject.ruby_value}"
    when MiqExpression::Regkey
      "<registry>#{exp[operator]["regkey"].strip} : #{exp[operator]["regval"]}</registry> == #{subject.ruby_value}"
    end
  end

  def visit_is_not_empty(subject)
    case subject.target
    when MiqExpression::Field
      "<value ref=#{subject.ref}, type=#{subject.column_type}>#{subject.to_tag}</value> != #{subject.ruby_value}"
    when MiqExpression::CountField
      "<count> != #{subject.ruby_value}"
    when MiqExpression::Count
      "<count ref=#{subject.ref}>#{subject.to_tag}</count> != #{subject.ruby_value}"
    when MiqExpression::Regkey
      "<registry>#{exp[operator]["regkey"].strip} : #{exp[operator]["regval"]}</registry> != #{subject.ruby_value}"
    end
  end

  def visit_not_equal(subject)
    case subject.target
    when MiqExpression::Field
      "<value ref=#{subject.ref}, type=#{subject.column_type}>#{subject.to_tag}</value> != #{subject.ruby_value}"
    when MiqExpression::CountField
      "<count> != #{subject.ruby_value}"
    when MiqExpression::Count
      "<count ref=#{subject.ref}>#{subject.to_tag}</count> != #{subject.ruby_value}"
    when MiqExpression::Regkey
      "<registry>#{exp[operator]["regkey"].strip} : #{exp[operator]["regval"]}</registry> != #{subject.ruby_value}"
    end
  end

  def visit_like(subject)
    value = "/" + re_escape(subject.value) + "/"
    case subject.target
    when MiqExpression::Field
      "<value ref=#{subject.ref}, type=#{subject.column_type}>#{subject.to_tag}</value> =~ #{value}"
    when MiqExpression::CountField
      "<count> =~ #{value}"
    when MiqExpression::Count
      "<count ref=#{subject.ref}>#{subject.to_tag}</count> =~ #{value}"
    when MiqExpression::Regkey
      "<registry>#{exp[operator]["regkey"].strip} : #{exp[operator]["regval"]}</registry> =~ #{value}"
    end
  end

  def visit_not_like(subject)
    value = "/" + re_escape(subject.value) + "/"
    case subject.target
    when MiqExpression::Field
      "!(<value ref=#{subject.ref}, type=#{subject.column_type}>#{subject.to_tag}</value> =~ #{value})"
    when MiqExpression::CountField
      "!(<count> =~ #{value})"
    when MiqExpression::Count
      "!(<count ref=#{subject.ref}>#{subject.to_tag}</count> =~ #{value})"
    when MiqExpression::Regkey
      "!(<registry>#{exp[operator]["regkey"].strip} : #{exp[operator]["regval"]}</registry> =~ #{value})"
    end
  end

  def visit_starts_with(subject)
    value = "/^" + re_escape(subject.value) + "/"
    case subject.target
    when MiqExpression::Field
      "<value ref=#{subject.ref}, type=#{subject.column_type}>#{subject.to_tag}</value> =~ #{value}"
    when MiqExpression::CountField
      "<count> =~ #{value}"
    when MiqExpression::Count
      "<count ref=#{subject.ref}>#{subject.to_tag}</count> =~ #{value}"
    when MiqExpression::Regkey
      "<registry>#{exp[operator]["regkey"].strip} : #{exp[operator]["regval"]}</registry> =~ #{value}"
    end
  end

  def visit_contains(subject)
    exp[operator]["tag"] ||= exp[operator]["field"]
    ref, val = value2tag(preprocess_managed_tag(exp[operator]["tag"]), exp[operator]["value"])
    "<exist ref=#{ref}>#{val}</exist>"
  end

  def visit_ends_with(subject)
    value = "/" + re_escape(subject.value) + "$/"
    case subject.target
    when MiqExpression::Field
      "<value ref=#{subject.ref}, type=#{subject.column_type}>#{subject.to_tag}</value> =~ #{value}"
    when MiqExpression::CountField
      "<count> =~ #{value}"
    when MiqExpression::Count
      "<count ref=#{subject.ref}>#{subject.to_tag}</count> =~ #{value}"
    when MiqExpression::Regkey
      "<registry>#{exp[operator]["regkey"].strip} : #{exp[operator]["regval"]}</registry> =~ #{value}"
    end
  end

  def visit_is_not_null(subject)
    case subject.target
    when MiqExpression::Field
      "<value ref=#{subject.ref}, type=#{subject.column_type}>#{subject.to_tag}</value> != #{subject.ruby_value}"
    when MiqExpression::CountField
      "<count> != #{subject.ruby_value}"
    when MiqExpression::Count
      "<count ref=#{subject.ref}>#{subject.to_tag}</count> != #{subject.ruby_value}"
    when MiqExpression::Regkey
      "<registry>#{exp[operator]["regkey"].strip} : #{exp[operator]["regval"]}</registry> != #{subject.ruby_value}"
    end
  end

  def visit_is_null(subject)
    case subject.target
    when MiqExpression::Field
      "<value ref=#{subject.ref}, type=#{subject.column_type}>#{subject.to_tag}</value> == #{subject.ruby_value}"
    when MiqExpression::CountField
      "<count> == #{subject.ruby_value}"
    when MiqExpression::Count
      "<count ref=#{subject.ref}>#{subject.to_tag}</count> == #{subject.ruby_value}"
    when MiqExpression::Regkey
      "<registry>#{exp[operator]["regkey"].strip} : #{exp[operator]["regval"]}</registry> == #{subject.ruby_value}"
    end
  end

  def visit_is(subject)
    col_name = exp[operator]["field"]
    col_type = get_col_type(exp[operator]["field"]) || "string"

    ref, val = value2tag(exp[operator]["field"])
    col_ruby = "<value ref=#{ref}, type=#{col_type}>#{val}</value>"

    col_type = get_col_type(col_name)
    value = exp[operator]["value"]
    if col_type == :date && !RelativeDatetime.relative?(value)
      ruby_for_date_compare(col_ruby, col_type, tz, "==", value)
    else
      ruby_for_date_compare(col_ruby, col_type, tz, ">=", value, "<=", value)
    end
  end

  def visit_from(subject)
    ""
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
    col_type = get_col_type(exp[operator]["field"])
    ref, val = value2tag(exp[operator]["field"])
    col_ruby = "<value ref=#{ref}, type=#{col_type}>#{val}</value>"

    ruby_for_date_compare(col_ruby, col_type, tz, "<", exp[operator]["value"])
  end

  def visit_after(subject)
    col_type = get_col_type(exp[operator]["field"])
    ref, val = value2tag(exp[operator]["field"])
    col_ruby = "<value ref=#{ref}, type=#{col_type}>#{val}</value>"
    ruby_for_date_compare(col_ruby, col_type, tz, nil, nil, ">", exp[operator]["value"])
  end

  def visit_regular_expression_matches(subject)
    operands = if exp[operator]["field"]
                 col_type = get_col_type(exp[operator]["field"]) || "string"
                 ref, val = value2tag(exp[operator]["field"])
                 fld = "<value ref=#{ref}, type=#{col_type}>#{val}</value>"
                 [fld, exp[operator]["value"]]
               elsif exp[operator]["regkey"]
                 fld = "<registry>#{exp[operator]["regkey"].strip} : #{exp[operator]["regval"]}</registry>"
                 [fld, exp[operator]["value"]]
               end

    # If it looks like a regular expression, sanitize from forward
    # slashes and interpolation
    #
    # Regular expressions with a single option are also supported,
    # e.g. "/abc/i"
    #
    # Otherwise sanitize the whole string and add the delimiters
    #
    # TODO: support regexes with more than one option
    if operands[1].starts_with?("/") && operands[1].ends_with?("/")
      operands[1][1..-2] = sanitize_regular_expression(operands[1][1..-2])
    elsif operands[1].starts_with?("/") && operands[1][-2] == "/"
      operands[1][1..-3] = sanitize_regular_expression(operands[1][1..-3])
    else
      operands[1] = "/" + sanitize_regular_expression(operands[1].to_s) + "/"
    end
    operands.join(" =~ ")
  end

  def visit_regular_expression_does_not_match(subject)
    operands = if exp[operator]["field"]
                 col_type = get_col_type(exp[operator]["field"]) || "string"
                 ref, val = value2tag(exp[operator]["field"])
                 fld = "<value ref=#{ref}, type=#{col_type}>#{val}</value>"
                 [fld, exp[operator]["value"]]
               elsif exp[operator]["regkey"]
                 fld = "<registry>#{exp[operator]["regkey"].strip} : #{exp[operator]["regval"]}</registry>"
                 [fld, exp[operator]["value"]]
               end

    # If it looks like a regular expression, sanitize from forward
    # slashes and interpolation
    #
    # Regular expressions with a single option are also supported,
    # e.g. "/abc/i"
    #
    # Otherwise sanitize the whole string and add the delimiters
    #
    # TODO: support regexes with more than one option
    if operands[1].starts_with?("/") && operands[1].ends_with?("/")
      operands[1][1..-2] = sanitize_regular_expression(operands[1][1..-2])
    elsif operands[1].starts_with?("/") && operands[1][-2] == "/"
      operands[1][1..-3] = sanitize_regular_expression(operands[1][1..-3])
    else
      operands[1] = "/" + sanitize_regular_expression(operands[1].to_s) + "/"
    end
    operands.join(" !~ ")
  end

  def visit_key_exists(subject)
    "<registry key_exists=1, type=boolean>#{subject.regkey}</registry>  == 'true'"
  end

  def visit_value_exists(subject)
    "<registry value_exists=1, type=boolean>#{subject.regkey} : #{subject.regval}</registry>  == 'true'"
  end

  def visit_includes_any(subject)
    col_type = get_col_type(exp[operator]["field"]) || "string"
    ref, val = value2tag(exp[operator]["field"])
    fld = "<value ref=#{ref}, type=#{col_type}>#{val}</value>"
    operands = [fld, quote(exp[operator]["value"], col_type.to_s)]
    "(#{operands[1]} - #{operands[0]}) != #{operands[1]}"
  end

  def visit_includes_all(subject)
    col_type = get_col_type(exp[operator]["field"]) || "string"
    ref, val = value2tag(exp[operator]["field"])
    fld = "<value ref=#{ref}, type=#{col_type}>#{val}</value>"
    operands = [fld, quote(exp[operator]["value"], col_type.to_s)]
    "(#{operands[0]} & #{operands[1]}) == #{operands[1]}"
  end

  def visit_includes_only(subject)
    col_type = get_col_type(exp[operator]["field"]) || "string"
    ref, val = value2tag(exp[operator]["field"])
    fld = "<value ref=#{ref}, type=#{col_type}>#{val}</value>"

    operands = [fld, quote(exp[operator]["value"], col_type.to_s)]
    "(#{operands[0]} - #{operands[1]}) == []"

  end

  def visit_limited_to(subject)
    col_type = get_col_type(exp[operator]["field"]) || "string"
    ref, val = value2tag(exp[operator]["field"])
    fld = "<value ref=#{ref}, type=#{col_type}>#{val}</value>"
    operands = [fld, quote(exp[operator]["value"], col_type.to_s)]
    "(#{operands[0]} - #{operands[1]}) == []"

  end

  def visit_find(subject)
    # FIND Vm.users-name = 'Administrator' CHECKALL Vm.users-enabled = 1
    check = nil
    check = "checkall" if exp[operator].include?("checkall")
    check = "checkany" if exp[operator].include?("checkany")
    if exp[operator].include?("checkcount")
      check = "checkcount"
      op = exp[operator][check].keys.first
      exp[operator][check][op]["field"] = "<count>"
    end
    raise _("expression malformed,  must contain one of 'checkall', 'checkany', 'checkcount'") unless check
    check =~ /^check(.*)$/; mode = $1.downcase
    "<find><search>" + _to_ruby(exp[operator]["search"], context_type, tz) + "</search><check mode=#{mode}>" + _to_ruby(exp[operator][check], context_type, tz) + "</check></find>"
  end

  def visit_from(subject)
    col_name = exp[operator]["field"]

    col_type = get_col_type(exp[operator]["field"]) || "string"
    ref, val = value2tag(exp[operator]["field"])
    col_ruby = "<value ref=#{ref}, type=#{col_type}>#{val}</value>"

    col_type = get_col_type(col_name)

    start_val, end_val = exp[operator]["value"]
    ruby_for_date_compare(col_ruby, col_type, tz, ">=", start_val, "<=", end_val)
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

  # Escape any unescaped forward slashes and/or interpolation
  def sanitize_regular_expression(string)
    string.gsub(%r{\\*/}, "\\/").gsub(/\\*#/, "\\\#")
  end
end
