class MiqExpression::Component::LessThanOrEqual < MiqExpression::Component::Leaf
  def to_arel(_timezone)
    target.lteq(value)
  end

  def to_ruby
    "<value ref=#{target.ref}, type=#{target.column_type}>#{target.to_tag}</value> <= #{value}"
  end
end
