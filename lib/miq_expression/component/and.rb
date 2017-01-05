class MiqExpression::Component::And < MiqExpression::Component::Composite
  def to_arel(timezone)
    first, *rest = sub_expressions.select(&:supports_sql?)
    return unless first
    rest.inject(first.to_arel(timezone)) { |arel, sub_expression| arel.and(sub_expression.to_arel(timezone)) }
  end

  def supports_sql?
    sub_expressions.any?(&:supports_sql?)
  end
end
