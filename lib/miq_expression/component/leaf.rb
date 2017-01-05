class MiqExpression::Component::Leaf < MiqExpression::Component::Base
  def self.build(options)
    target = if options.key?("field")
               MiqExpression::Field.parse(options["field"])
             elsif options.key?("count")
               nil
             elsif options.key?("regkey")
               nil
             end

    value = if MiqExpression::Field.is_field?(options["value"])
              MiqExpression::Field.parse(options["value"]).arel_attribute
            else
              options["value"]
            end
    new(target, value)
  end

  attr_reader :target, :value

  def initialize(target, value)
    @target = target
    @value = value
  end

  def supports_sql?
    target.kind_of?(MiqExpression::Tag)
    # target.kind_of?(MiqExpression::Regkey)
    # target.kind_of?(MiqExpression::Count)
    target.supports_sql?
  end
end
