class MiqExpression::Visitors::RubyVisitor
  attr_reader :timezone

  def initialize(timezone = "UTC")
    @timezone = timezone
  end

  def visit(subject)
    method_name = :"visit_#{subject.class.name.split("::").last.underscore}"
    public_send(method_name, subject)
  end

  def visit_equal(subject)
    ""
  end

  def visit_less_than(subject)
    ""
  end

  def visit_less_than_or_equal(subject)
    ""
  end

  def visit_greater_than(subject)
    ""
  end

  def visit_greater_than_or_equal(subject)
    ""
  end

  def visit_is_empty(subject)
    ""
  end

  def visit_is_not_empty(subject)
    ""
  end

  def visit_not_equal(subject)
    ""
  end

  def visit_like(subject)
    ""
  end

  def visit_not_like(subject)
    ""
  end

  def visit_starts_with(subject)
    ""
  end

  def visit_contains(subject)
    ""
  end

  def visit_ends_with(subject)
    ""
  end

  def visit_is_not_null(subject)
    ""
  end

  def visit_is_null(subject)
    ""
  end

  def visit_is(subject)
    ""
  end

  def visit_from(subject)
    ""
  end

  def visit_not(subject)
    ""
  end

  def visit_or(subject)
    ""
  end

  def visit_and(subject)
    ""
  end

  def visit_before(subject)
    ""
  end

  def visit_after(subject)
    ""
  end

  def visit_regular_expression_matches(subject)
    ""
  end

  def visit_regular_expression_does_not_match(subject)
    ""
  end

  def visit_key_exists(subject)
    ""
  end

  def visit_includes_any(subject)
    ""
  end

  def visit_includes_all(subject)
    ""
  end
end
