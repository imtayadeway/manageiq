class MiqExpression::Component::StartsWith < MiqExpression::Component::Leaf
  def to_arel(_timezone)
    target.matches("#{value}%") if supports_sql?
  end
end
