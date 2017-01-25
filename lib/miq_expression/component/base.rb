class MiqExpression::Component::Base
  def self.build
    raise "Called abtract method: .build"
  end

  def accept(visitor)
    visitor.visit(self)
  end
end
