class MiqExpression::Component::After < MiqExpression::Component::Leaf
  def to_arel(timezone)
    target.gt(MiqExpression::RelativeDatetime.normalize(sql_value, timezone, "end", target.date?)) if supports_sql?
  end
end
