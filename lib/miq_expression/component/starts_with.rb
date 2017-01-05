class MiqExpression::Component::StartsWith < MiqExpression::Component::Leaf
  def to_arel(_timezone)
    target.matches("#{sql_value}%") if supports_sql?
  end
end
