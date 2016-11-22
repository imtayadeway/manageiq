class MiqExpression::Component::Equal < MiqExpression::Component::Leaf
  def to_arel(_timezone)
    target.eq(value)
  end

  def to_ruby
    "<value ref=#{target.ref}, type=#{target.column_type}>#{target.to_tag}</value> == \"#{value}\""
  end
end
