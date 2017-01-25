module MiqExpression::Component
  class MiqExpression::Component::Base
    def self.build
      raise "Called abtract method: .build"
    end

    def accept(visitor)
      visitor.visit(self)
    end
  end

  class MiqExpression::Component::Leaf < MiqExpression::Component::Base
    def self.build(options)
      value = if MiqExpression::Field.is_field?(options["value"])
                MiqExpression::Field.parse(options["value"]).arel_attribute
              else
                options["value"]
              end
      new(MiqExpression::Field.parse(options["field"]), value)
    end

    attr_reader :target, :value

    def initialize(target, value)
      @target = target
      @value = value
    end
  end

  class MiqExpression::Component::Composite < MiqExpression::Component::Base
    def self.build(sub_expressions)
      new(sub_expressions.map { |e| MiqExpression::Component.build(e) })
    end

    attr_reader :sub_expressions

    def initialize(sub_expressions)
      @sub_expressions = sub_expressions
    end
  end

  class MiqExpression::Component::SingleComposite < MiqExpression::Component::Base
    def self.build(sub_expression)
      new(MiqExpression::Component.build(sub_expression))
    end

    attr_reader :sub_expression

    def initialize(sub_expression)
      @sub_expression = sub_expression
    end
  end

  MiqExpression::Component::After = Class.new(MiqExpression::Component::Leaf)
  MiqExpression::Component::And = Class.new(MiqExpression::Component::Composite)
  MiqExpression::Component::Before = Class.new(MiqExpression::Component::Leaf)

  class MiqExpression::Component::Contains < MiqExpression::Component::Leaf
    def self.build(options)
      target = if options["tag"]
                 MiqExpression::Tag.parse(options["tag"])
               else
                 MiqExpression::Field.parse(options["field"])
               end
      new(target, options["value"])
    end
  end

  MiqExpression::Component::EndsWith = Class.new(MiqExpression::Component::Leaf)
  MiqExpression::Component::Equal = Class.new(MiqExpression::Component::Leaf)

  class MiqExpression::Component::From < MiqExpression::Component::Leaf
    def start_value(timezone)
      MiqExpression::RelativeDatetime.normalize(value[0], timezone, "beginning", target.date?)
    end

    def end_value(timezone)
      MiqExpression::RelativeDatetime.normalize(value[1], timezone, "end", target.date?)
    end
  end

  MiqExpression::Component::GreaterThan = Class.new(MiqExpression::Component::Leaf)
  MiqExpression::Component::GreaterThanOrEqual = Class.new(MiqExpression::Component::Leaf)

  class MiqExpression::Component::Is < MiqExpression::Component::Leaf
    def start_value(timezone)
      MiqExpression::RelativeDatetime.normalize(value, timezone, "beginning", target.date?)
    end

    def end_value(timezone)
      MiqExpression::RelativeDatetime.normalize(value, timezone, "end", target.date?)
    end
  end

  MiqExpression::Component::IsEmpty = Class.new(MiqExpression::Component::Leaf)
  MiqExpression::Component::IsNotEmpty = Class.new(MiqExpression::Component::Leaf)
  MiqExpression::Component::IsNotNull = Class.new(MiqExpression::Component::Leaf)
  MiqExpression::Component::IsNull = Class.new(MiqExpression::Component::Leaf)
  MiqExpression::Component::LessThan = Class.new(MiqExpression::Component::Leaf)
  MiqExpression::Component::LessThanOrEqual = Class.new(MiqExpression::Component::Leaf)
  MiqExpression::Component::Like = Class.new(MiqExpression::Component::Leaf)
  MiqExpression::Component::Not = Class.new(MiqExpression::Component::SingleComposite)
  MiqExpression::Component::NotEqual = Class.new(MiqExpression::Component::Leaf)
  MiqExpression::Component::NotLike = Class.new(MiqExpression::Component::Leaf)
  MiqExpression::Component::Or = Class.new(MiqExpression::Component::Composite)
  MiqExpression::Component::StartsWith = Class.new(MiqExpression::Component::Leaf)

  TYPES = {
    "!"            => Not,
    "!="           => NotEqual,
    "<"            => LessThan,
    "<="           => LessThanOrEqual,
    "="            => Equal,
    ">"            => GreaterThan,
    ">="           => GreaterThanOrEqual,
    "after"        => After,
    "and"          => And,
    "before"       => Before,
    "contains"     => Contains,
    "ends with"    => EndsWith,
    "equal"        => Equal,
    "from"         => From,
    "includes"     => Like,
    "is empty"     => IsEmpty,
    "is not empty" => IsNotEmpty,
    "is not null"  => IsNotNull,
    "is null"      => IsNull,
    "is"           => Is,
    "like"         => Like,
    "not like"     => NotLike,
    "not"          => Not,
    "or"           => Or,
    "starts with"  => StartsWith
  }.freeze

  def self.for_operator(operator)
    TYPES[operator.downcase] or raise _("operator '%{operator_name}' is not supported") % {:operator_name => operator}
  end

  def self.build(expression)
    operator = expression.keys.first
    for_operator(operator).build(expression[operator])
  end
end
