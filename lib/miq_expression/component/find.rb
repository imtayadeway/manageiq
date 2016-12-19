class MiqExpression::Component::Find < MiqExpression::Component::Composite
  def self.build(options, timezone)
    value = if MiqExpression::Field.valid_field?(options["value"])
              MiqExpression::Field.parse(options["value"]).arel_attribute
            else
              options["value"]
            end
    new(MiqExpression::Field.parse(options["field"]), value, timezone)



  end
end
