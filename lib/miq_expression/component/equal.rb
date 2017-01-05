class MiqExpression::Component::Equal < MiqExpression::Component::Leaf
  def to_arel(_timezone)
    target.eq(sql_value) if supports_sql?
  end
end
