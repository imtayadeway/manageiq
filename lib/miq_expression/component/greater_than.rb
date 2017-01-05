class MiqExpression::Component::GreaterThan < MiqExpression::Component::Leaf
  def to_arel(_timezone)
    target.gt(sql_value) if supports_sql?
  end
end
