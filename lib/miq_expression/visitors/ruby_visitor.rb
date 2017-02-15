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
    operands = case subject
    when MiqExpression::Field
      if exp[operator]["field"] == "<count>"
        ["<count>", quote(exp[operator]["value"], "integer")]
      else
        col_type = subject.column_type
        case context_type
        when "hash"
          fld = "<value type=#{col_type}>#{subject.value}</value>"
        else
          ref, val = value2tag(exp[operator]["field"])
          fld = "<value ref=#{ref}, type=#{col_type}>#{val}</value>"
        end
        [fld, subject.value]
      end
    when MiqExpression::Count
      ref, count = value2tag(exp[operator]["count"])
      field = "<count ref=#{ref}>#{count}</count>"
      [field, quote(exp[operator]["value"], "integer")]
    when MiqExpression::Regkey
      fld = "<registry>#{exp[operator]["regkey"].strip} : #{exp[operator]["regval"]}</registry>"
      [fld, quote(exp[operator]["value"], "string")]
    end
    operands.join(" == ")
  end

  def visit_less_than(subject)
    operands = if exp[operator]["field"]
                 if exp[operator]["field"] == "<count>"
                   ["<count>", quote(exp[operator]["value"], "integer")]
                 else
                   col_type = get_col_type(exp[operator]["field"]) || "string"
                   case context_type
                   when "hash"
                     val = exp[operator]["field"].split(".").last.split("-").join(".")
                     fld = "<value type=#{col_type}>#{val}</value>"
                   else
                     ref, val = value2tag(exp[operator]["field"])
                     fld = "<value ref=#{ref}, type=#{col_type}>#{val}</value>"
                   end
                   [fld, quote(exp[operator]["value"], col_type.to_s)]
                 end
               elsif exp[operator]["count"]
                 ref, count = value2tag(exp[operator]["count"])
                 field = "<count ref=#{ref}>#{count}</count>"
                 [field, quote(exp[operator]["value"], "integer")]
               end
    operands.join(" < ")
  end

  def visit_less_than_or_equal(subject)
    operands = if exp[operator]["field"]
                 if exp[operator]["field"] == "<count>"
                   ["<count>", quote(exp[operator]["value"], "integer")]
                 else
                   col_type = get_col_type(exp[operator]["field"]) || "string"
                   case context_type
                   when "hash"
                     val = exp[operator]["field"].split(".").last.split("-").join(".")
                     fld = "<value type=#{col_type}>#{val}</value>"
                   else
                     ref, val = value2tag(exp[operator]["field"])
                     fld = "<value ref=#{ref}, type=#{col_type}>#{val}</value>"
                   end
                   [fld, quote(exp[operator]["value"], col_type.to_s)]
                 end
               elsif exp[operator]["count"]
                 ref, count = value2tag(exp[operator]["count"])
                 field = "<count ref=#{ref}>#{count}</count>"
                 [field, quote(exp[operator]["value"], "integer")]
               end
    operands.join(" <= ")
  end

  def visit_greater_than(subject)
    operands = if exp[operator]["field"]
                 if exp[operator]["field"] == "<count>"
                   ["<count>", quote(exp[operator]["value"], "integer")]
                 else
                   col_type = get_col_type(exp[operator]["field"]) || "string"
                   case context_type
                   when "hash"
                     val = exp[operator]["field"].split(".").last.split("-").join(".")
                     fld = "<value type=#{col_type}>#{val}</value>"
                   else
                     ref, val = value2tag(exp[operator]["field"])
                     fld = "<value ref=#{ref}, type=#{col_type}>#{val}</value>"
                   end
                   [fld, quote(exp[operator]["value"], col_type.to_s)]
                 end
               elsif exp[operator]["count"]
                 ref, count = value2tag(exp[operator]["count"])
                 field = "<count ref=#{ref}>#{count}</count>"
                 [field, quote(exp[operator]["value"], "integer")]
               end
    operands.join(" > ")
  end

  def visit_greater_than_or_equal(subject)
    operands = if exp[operator]["field"]
                 if exp[operator]["field"] == "<count>"
                   ["<count>", quote(exp[operator]["value"], "integer")]
                 else
                   col_type = get_col_type(exp[operator]["field"]) || "string"
                   case context_type
                   when "hash"
                     val = exp[operator]["field"].split(".").last.split("-").join(".")
                     fld = "<value type=#{col_type}>#{val}</value>"
                   else
                     ref, val = value2tag(exp[operator]["field"])
                     fld = "<value ref=#{ref}, type=#{col_type}>#{val}</value>"
                   end
                   [fld, quote(exp[operator]["value"], col_type.to_s)]
                 end
               elsif exp[operator]["count"]
                 ref, count = value2tag(exp[operator]["count"])
                 field = "<count ref=#{ref}>#{count}</count>"
                 [field, quote(exp[operator]["value"], "integer")]
               end
    operands.join(" >= ")
  end

  def visit_is_empty(subject)
    operands = if exp[operator]["field"]
                 col_type = get_col_type(exp[operator]["field"]) || "string"
                 case context_type
                 when "hash"
                   val = exp[operator]["field"].split(".").last.split("-").join(".")
                   fld = "<value type=#{col_type}>#{val}</value>"
                 else
                   ref, val = value2tag(exp[operator]["field"])
                   fld = "<value ref=#{ref}, type=#{col_type}>#{val}</value>"
                 end

                 [fld, quote(exp[operator]["value"], col_type.to_s)]
               elsif exp[operator]["regkey"]
                 fld = "<registry>#{exp[operator]["regkey"].strip} : #{exp[operator]["regval"]}</registry>"
                 [fld, quote(exp[operator]["value"], "string")]
               end
    operands.join(" == ")
  end

  def visit_is_not_empty(subject)
    operands = if exp[operator]["field"]
                 col_type = get_col_type(exp[operator]["field"]) || "string"
                 case context_type
                 when "hash"
                   val = exp[operator]["field"].split(".").last.split("-").join(".")
                   fld = "<value type=#{col_type}>#{val}</value>"
                 else
                   ref, val = value2tag(exp[operator]["field"])
                   fld = "<value ref=#{ref}, type=#{col_type}>#{val}</value>"
                 end
                 [fld, quote(exp[operator]["value"], col_type.to_s)]
               elsif exp[operator]["regkey"]
                 fld = "<registry>#{exp[operator]["regkey"].strip} : #{exp[operator]["regval"]}</registry>"
                 [fld, quote(exp[operator]["value"], "string")]
               end
    operands.join(" != ")
  end

  def visit_not_equal(subject)
    operands = if exp[operator]["field"]
                 if exp[operator]["field"] == "<count>"
                   ["<count>", quote(exp[operator]["value"], "integer")]
                 else
                   col_type = get_col_type(exp[operator]["field"]) || "string"
                   case context_type
                   when "hash"
                     val = exp[operator]["field"].split(".").last.split("-").join(".")
                     fld = "<value type=#{col_type}>#{val}</value>"
                   else
                     ref, val = value2tag(exp[operator]["field"])
                     fld = "<value ref=#{ref}, type=#{col_type}>#{val}</value>"
                   end
                   operands = [fld, quote(exp[operator]["value"], col_type.to_s)]
                 end
               elsif exp[operator]["count"]
                 ref, count = value2tag(exp[operator]["count"])
                 field = "<count ref=#{ref}>#{count}</count>"
                 [field, quote(exp[operator]["value"], "integer")]
               end
    operands.join(" != ")
  end

  def visit_like(subject)
    operands = if exp[operator]["field"]
                 col_type = get_col_type(exp[operator]["field"]) || "string"
                 case context_type
                 when "hash"
                   val = exp[operator]["field"].split(".").last.split("-").join(".")
                   fld = "<value type=#{col_type}>#{val}</value>"
                 else
                   ref, val = value2tag(exp[operator]["field"])
                   fld = "<value ref=#{ref}, type=#{col_type}>#{val}</value>"
                 end

                 [fld, exp[operator]["value"]]
               elsif exp[operator]["regkey"] # hmmm, not in the UI
                 fld = "<registry>#{exp[operator]["regkey"].strip} : #{exp[operator]["regval"]}</registry>"
                 [fld, exp[operator]["value"]]
               end
    operands[1] = "/" + re_escape(operands[1].to_s) + "/"
    operands.join(" =~ ")
  end

  def visit_not_like(subject)
    operands = if exp[operator]["field"]
                 col_type = get_col_type(exp[operator]["field"]) || "string"
                 case context_type
                 when "hash"
                   val = exp[operator]["field"].split(".").last.split("-").join(".")
                   fld = "<value type=#{col_type}>#{val}</value>"
                 else
                   ref, val = value2tag(exp[operator]["field"])
                   fld = "<value ref=#{ref}, type=#{col_type}>#{val}</value>"
                 end

                 [fld, exp[operator]["value"]]
               elsif exp[operator]["regkey"] # hmmm, not in the UI
                 fld = "<registry>#{exp[operator]["regkey"].strip} : #{exp[operator]["regval"]}</registry>"
                 [fld, exp[operator]["value"]]
               end
    operands[1] = "/" + re_escape(operands[1].to_s) + "/"
    "!(" + operands.join(" =~ ") + ")"
  end

  def visit_starts_with(subject)
    operands = if exp[operator]["field"]
                 col_type = get_col_type(exp[operator]["field"]) || "string"
                 case context_type
                 when "hash"
                   val = exp[operator]["field"].split(".").last.split("-").join(".")
                   fld = "<value type=#{col_type}>#{val}</value>"
                 else
                   ref, val = value2tag(exp[operator]["field"])
                   fld = "<value ref=#{ref}, type=#{col_type}>#{val}</value>"
                 end

                 [fld, exp[operator]["value"]]
               elsif exp[operator]["regkey"]
                 fld = "<registry>#{exp[operator]["regkey"].strip} : #{exp[operator]["regval"]}</registry>"
                 [fld, exp[operator]["value"]]
               end
    operands[1] = "/^" + re_escape(operands[1].to_s) + "/"
    clause = operands.join(" =~ ")
  end

  def visit_contains(subject)
    exp[operator]["tag"] ||= exp[operator]["field"]
    operands = if context_type != "hash"
                 ref, val = value2tag(preprocess_managed_tag(exp[operator]["tag"]), exp[operator]["value"])
                 ["<exist ref=#{ref}>#{val}</exist>"]
               elsif context_type == "hash"
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
               end
    operands.join(" CONTAINS ")
  end

  def visit_ends_with(subject)
    operands = if exp[operator]["field"]
                 col_type = get_col_type(exp[operator]["field"]) || "string"
                 case context_type
                 when "hash"
                   val = exp[operator]["field"].split(".").last.split("-").join(".")
                   fld = "<value type=#{col_type}>#{val}</value>"
                 else
                   ref, val = value2tag(exp[operator]["field"])
                   fld = "<value ref=#{ref}, type=#{col_type}>#{val}</value>"
                 end

                 [fld, exp[operator]["value"]]
               elsif exp[operator]["regkey"]
                 fld = "<registry>#{exp[operator]["regkey"].strip} : #{exp[operator]["regval"]}</registry>"
                 [fld, exp[operator]["value"]]
               end
    operands[1] = "/" + re_escape(operands[1].to_s) + "$/"
    operands.join(" =~ ")
  end

  def visit_is_not_null(subject)
    operands = if exp[operator]["field"]
                 col_type = get_col_type(exp[operator]["field"]) || "string"
                 case context_type
                 when "hash"
                   val = exp[operator]["field"].split(".").last.split("-").join(".")
                   fld = "<value type=#{col_type}>#{val}</value>"
                 else
                   ref, val = value2tag(exp[operator]["field"])
                   fld = "<value ref=#{ref}, type=#{col_type}>#{val}</value>"
                 end

                 [fld, quote(exp[operator]["value"], col_type.to_s)]
               elsif exp[operator]["regkey"]
                 fld = "<registry>#{exp[operator]["regkey"].strip} : #{exp[operator]["regval"]}</registry>"
                 [fld, quote(exp[operator]["value"], "string")]
               end
    operands.join(" != ")
  end

  def visit_is_null(subject)
    operands = if exp[operator]["field"]
                 col_type = get_col_type(exp[operator]["field"]) || "string"
                 case context_type
                 when "hash"
                   val = exp[operator]["field"].split(".").last.split("-").join(".")
                   fld = "<value type=#{col_type}>#{val}</value>"
                 else
                   ref, val = value2tag(exp[operator]["field"])
                   fld = "<value ref=#{ref}, type=#{col_type}>#{val}</value>"
                 end

                 [fld, quote(exp[operator]["value"], col_type.to_s)]
               elsif exp[operator]["regkey"]
                 fld = "<registry>#{exp[operator]["regkey"].strip} : #{exp[operator]["regval"]}</registry>"
                 [fld, quote(exp[operator]["value"], "string")]
               end
    operands.join(" == ")
  end

  def visit_is(subject)
    col_name = exp[operator]["field"]
    col_type = get_col_type(exp[operator]["field"]) || "string"

    col_ruby = case context_type
               when "hash"
                 val = exp[operator]["field"].split(".").last.split("-").join(".")
                 "<value type=#{col_type}>#{val}</value>"
               else
                 ref, val = value2tag(exp[operator]["field"])
                 "<value ref=#{ref}, type=#{col_type}>#{val}</value>"
               end

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
    "!" + "(" + _to_ruby(exp[operator], context_type, tz) + ")"
  end

  def visit_or(subject)
    "(" + exp[operator].collect { |operand| _to_ruby(operand, context_type, tz) }.join(" or ") + ")"
  end

  def visit_and(subject)
    "(" + exp[operator].collect { |operand| _to_ruby(operand, context_type, tz) }.join(" and ") + ")"
  end

  def visit_before(subject)
    col_type = get_col_type(exp[operator]["field"])
    col_ruby = case context_type
               when "hash"
                 val = exp[operator]["field"].split(".").last.split("-").join(".")
                 "<value type=#{col_type}>#{val}</value>"
               else
                 ref, val = value2tag(exp[operator]["field"])
                 "<value ref=#{ref}, type=#{col_type}>#{val}</value>"
               end

    ruby_for_date_compare(col_ruby, col_type, tz, "<", exp[operator]["value"])
  end

  def visit_after(subject)
    col_type = get_col_type(exp[operator]["field"])
    col_ruby = case context_type
               when "hash"
                 val = exp[operator]["field"].split(".").last.split("-").join(".")
                 "<value type=#{col_type}>#{val}</value>"
               else
                 ref, val = value2tag(exp[operator]["field"])
                 "<value ref=#{ref}, type=#{col_type}>#{val}</value>"
               end

    ruby_for_date_compare(col_ruby, col_type, tz, nil, nil, ">", exp[operator]["value"])
  end

  def visit_regular_expression_matches(subject)
    operands = if exp[operator]["field"]
                 col_type = get_col_type(exp[operator]["field"]) || "string"
                 case context_type
                 when "hash"
                   val = exp[operator]["field"].split(".").last.split("-").join(".")
                   fld = "<value type=#{col_type}>#{val}</value>"
                 else
                   ref, val = value2tag(exp[operator]["field"])
                   fld = "<value ref=#{ref}, type=#{col_type}>#{val}</value>"
                 end

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
                 case context_type
                 when "hash"
                   val = exp[operator]["field"].split(".").last.split("-").join(".")
                   fld = "<value type=#{col_type}>#{val}</value>"
                 else
                   ref, val = value2tag(exp[operator]["field"])
                   fld = "<value ref=#{ref}, type=#{col_type}>#{val}</value>"
                 end

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
    "<registry key_exists=1, type=boolean>#{exp[operator]["regkey"].strip}</registry>  == 'true'"
  end

  def visit_value_exists(subject)
    "<registry value_exists=1, type=boolean>#{exp[operator]["regkey"].strip} : #{exp[operator]["regval"]}</registry>  == 'true'"
  end

  def visit_includes_any(subject)
    col_type = get_col_type(exp[operator]["field"]) || "string"
    case context_type
    when "hash"
      val = exp[operator]["field"].split(".").last.split("-").join(".")
      fld = "<value type=#{col_type}>#{val}</value>"
    else
      ref, val = value2tag(exp[operator]["field"])
      fld = "<value ref=#{ref}, type=#{col_type}>#{val}</value>"
    end

    operands = [fld, quote(exp[operator]["value"], col_type.to_s)]
    "(#{operands[1]} - #{operands[0]}) != #{operands[1]}"
  end

  def visit_includes_all(subject)
    col_type = get_col_type(exp[operator]["field"]) || "string"
    case context_type
    when "hash"
      val = exp[operator]["field"].split(".").last.split("-").join(".")
      fld = "<value type=#{col_type}>#{val}</value>"
    else
      ref, val = value2tag(exp[operator]["field"])
      fld = "<value ref=#{ref}, type=#{col_type}>#{val}</value>"
    end

    operands = [fld, quote(exp[operator]["value"], col_type.to_s)]
    "(#{operands[0]} & #{operands[1]}) == #{operands[1]}"
  end

  def visit_includes_only(subject)
    col_type = get_col_type(exp[operator]["field"]) || "string"
    case context_type
    when "hash"
      val = exp[operator]["field"].split(".").last.split("-").join(".")
      fld = "<value type=#{col_type}>#{val}</value>"
    else
      ref, val = value2tag(exp[operator]["field"])
      fld = "<value ref=#{ref}, type=#{col_type}>#{val}</value>"
    end

    operands = [fld, quote(exp[operator]["value"], col_type.to_s)]
    "(#{operands[0]} - #{operands[1]}) == []"

  end

  def visit_limited_to(subject)
    col_type = get_col_type(exp[operator]["field"]) || "string"
    case context_type
    when "hash"
      val = exp[operator]["field"].split(".").last.split("-").join(".")
      fld = "<value type=#{col_type}>#{val}</value>"
    else
      ref, val = value2tag(exp[operator]["field"])
      fld = "<value ref=#{ref}, type=#{col_type}>#{val}</value>"
    end

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
    col_ruby = case context_type
               when "hash"
                 val = exp[operator]["field"].split(".").last.split("-").join(".")
                 "<value type=#{col_type}>#{val}</value>"
               else
                 ref, val = value2tag(exp[operator]["field"])
                 "<value ref=#{ref}, type=#{col_type}>#{val}</value>"
               end

    col_type = get_col_type(col_name)

    start_val, end_val = exp[operator]["value"]
    ruby_for_date_compare(col_ruby, col_type, tz, ">=", start_val, "<=", end_val)
  end
end
