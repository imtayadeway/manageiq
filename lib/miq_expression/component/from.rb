class MiqExpression::Component::From < MiqExpression::Component::Leaf
  def to_arel(timezone)
    return unless supports_sql?
    start_value = MiqExpression::RelativeDatetime.normalize(sql_value[0], timezone, "beginning", target.date?)
    end_value   = MiqExpression::RelativeDatetime.normalize(sql_value[1], timezone, "end", target.date?)
    target.between(start_value..end_value)
  end
end
