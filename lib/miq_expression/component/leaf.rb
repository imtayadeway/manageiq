class MiqExpression::Component::Leaf < MiqExpression::Component::Base
  def self.build(options)
    target = if options.key?("field")
               MiqExpression::Field.parse(options["field"])
             elsif options.key?("count")
               MiqExpression::Count.new
             elsif options.key?("regkey")
               MiqExpression::Regkey.new
             end

    new(target, options["value"])
  end

  attr_reader :target, :value

  def initialize(target, value)
    @target = target
    @value = value
  end

  def supports_sql?
    target.supports_sql? && value_in_sql?
  end

  def value_in_sql?
    !MiqExpression::Field.is_field?(value) || MiqExpression::Field.parse(value).attribute_supported_by_sql?
  end

  def sql_value
    if MiqExpression::Field.is_field?(value)
      MiqExpression::Field.parse(value).arel_attribute
    else
      value
    end
  end

  def includes
    return {} unless supports_sql?
    target.associations.reverse.inject({}) { |hsh, association| {association.to_sym => hsh}}
  end
end
