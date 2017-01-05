class MiqExpression::Component::Base
  def self.build
    raise "Called abtract method: .build"
  end

  def to_sql(timezone)
    arel = to_arel(timezone)
    arel && arel.to_sql
  end

  def to_arel(_timezone)
    raise "Called abstract method: #to_arel"
  end

  def supports_sql?
    raise "Called abstract method: #supports_sql?"
  end

  def includes
    raise "Called abstract method: #includes"
  end
end
