class MiqExpression::Component::Leaf < MiqExpression::Component::Base
  def self.build(options)
    value = if MiqExpression::Field.is_field?(options["value"])
              MiqExpression::Field.parse(options["value"]).arel_attribute
            else
              options["value"]
            end
    new(MiqExpression::Field.parse(options["field"]), value)
  end

  attr_reader :target

  def initialize(target, value)
    @target = target
    @value = value
  end

  def value
    case target.column_type
    when :string, :text, :boolean, nil
      @value.to_s.inspect
    when :date
      if @value.blank?
        "nil"
      else
        "\'#{val}\'.to_date"
      end
    when :datetime
      if @value.blank?
        "nil"
      else
        "\'#{val.iso8601}\'.to_time(:utc)"
      end
    when :integer, :decimal, :fixnum
      @value.to_s.to_i_with_method
    when :float
      @value.to_s.to_f_with_method
    when :numeric_set
      val = @value.split(",") if @value.kind_of?(String)
      v_arr = val.to_miq_a.flat_map do |v|
        v = eval(v) rescue nil if v.kind_of?(String)
        v.kind_of?(Range) ? v.to_a : v
      end.compact.uniq.sort
      "[#{v_arr.join(",")}]"
    when :string_set
      val = @value.split(",") if @value.kind_of?(String)
      v_arr = val.to_miq_a.flat_map { |v| "'#{v.to_s.strip}'" }.uniq.sort
      "[#{v_arr.join(",")}]"
    else
      @value
    end
  end
end
