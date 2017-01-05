class MiqExpression::Component::NotEqual < MiqExpression::Component::Leaf
  def to_arel(_timezone)
    target.not_eq(sql_value) if supports_sql?
  end
end
