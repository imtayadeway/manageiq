class MiqExpression::Component::Or < MiqExpression::Component::Composite
  def to_arel(timezone)
    first, *rest = sub_expressions
    rest.inject(first.to_arel(timezone)) { |arel, sub_expression| arel.or(sub_expression.to_arel(timezone)) }
  end
end
