class MiqExpression::Component::Before < MiqExpression::Component::Leaf
  def to_arel(timezone)
    target.lt(MiqExpression::RelativeDatetime.normalize(sql_value, timezone, "beginning", target.date?)) if supports_sql?
  end
end
