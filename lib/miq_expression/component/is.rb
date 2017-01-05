class MiqExpression::Component::Is < MiqExpression::Component::Leaf
  def to_arel(timezone)
    return unless supports_sql?
    start_val = MiqExpression::RelativeDatetime.normalize(sql_value, timezone, "beginning", target.date?)
    end_val = MiqExpression::RelativeDatetime.normalize(sql_value, timezone, "end", target.date?)

    if !target.date? || MiqExpressionRelativeDatetime.relative?(sql_value)
      target.between(start_val..end_val)
    else
      target.eq(start_val)
    end
  end
end
