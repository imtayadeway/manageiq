class MiqExpression::Coercer
  def self.coerce(val, typ)
    if MiqExpression::Field.is_field?(val)
      ref, value = value2tag(val)
      col_type = get_col_type(val) || "string"
      return ref ? "<value ref=#{ref}, type=#{col_type}>#{value}</value>" : "<value type=#{col_type}>#{value}</value>"
    end
    case typ.to_s
    when "string", "text", "boolean", nil
      # escape any embedded single quotes, etc. - needs to be able to handle even values with trailing backslash
      val.to_s.inspect
    when "date"
      return "nil" if val.blank? # treat nil value as empty string
      "\'#{val}\'.to_date"
    when "datetime"
      return "nil" if val.blank? # treat nil value as empty string
      "\'#{val.iso8601}\'.to_time(:utc)"
    when "integer", "decimal", "fixnum"
      val.to_s.to_i_with_method
    when "float"
      val.to_s.to_f_with_method
    when "numeric_set"
      val = val.split(",") if val.kind_of?(String)
      v_arr = val.to_miq_a.flat_map do |v|
        v = eval(v) rescue nil if v.kind_of?(String)
        v.kind_of?(Range) ? v.to_a : v
      end.compact.uniq.sort
      "[#{v_arr.join(",")}]"
    when "string_set"
      val = val.split(",") if val.kind_of?(String)
      v_arr = val.to_miq_a.flat_map { |v| "'#{v.to_s.strip}'" }.uniq.sort
      "[#{v_arr.join(",")}]"
    else
      val
    end
  end
end
