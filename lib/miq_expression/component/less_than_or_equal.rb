class MiqExpression::Component::LessThanOrEqual < MiqExpression::Component::Leaf
  def to_arel(_timezone)
    target.lteq(sql_value) if supports_sql?
  end
end
