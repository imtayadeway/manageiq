class MiqExpression::Component::IsEmpty < MiqExpression::Component::Leaf
  def to_arel(_timezone)
    return unless supports_sql?
    arel = target.eq(nil)
    arel = arel.or(target.eq("")) if target.string?
    arel
  end
end
