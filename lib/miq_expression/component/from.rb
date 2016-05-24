class MiqExpression::Component::From < MiqExpression::Component::Leaf
  def to_arel(timezone)
    start_value = MiqExpression::RelativeDatetime.normalize(value[0], timezone, _mode = "beginning", target.date?)
    end_value   = MiqExpression::RelativeDatetime.normalize(value[1], timezone, _mode = "end", target.date?)
    target.between(start_value..end_value)
  end
end
