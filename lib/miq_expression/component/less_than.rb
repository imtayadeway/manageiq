class MiqExpression::Component::LessThan < MiqExpression::Component::Leaf
  def to_arel(_timezone)
    target.lt(value) if supports_sql?
  end
end
