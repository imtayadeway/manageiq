module MiqExpression::Component
  class MiqExpression::Count < MiqExpression::Field
  end

  class MiqExpression::Regkey
    attr_reader :regkey, :regval

    def initialize(options)
      @regkey = options["regkey"]
      @regval = options["regval"]
    end

    def arel_attribute
      nil
    end

    def column_type
      "string"
    end
  end

  class MiqExpression::Component::Base
    def self.build(_options)
      raise "Called abtract method: .build"
    end

    def accept(visitor)
      visitor.visit(self)
    end

    def sql?
      raise "Called abstract method: #sql?"
    end
  end

  class MiqExpression::Component::Leaf < MiqExpression::Component::Base
    def self.build(options)
      target = if options.key?("field")
                 MiqExpression::Field.parse(options["field"])
               elsif options.key?("count")
                 MiqExpression::Count.parse(options["count"])
               elsif options.key?("regkey")
                 MiqExpression::Regkey.new(options)
               end
      new(target, options["value"])
    end

    attr_reader :target

    def initialize(target, value)
      @target = target
      @value = value
    end

    def value
      if MiqExpression::Field.is_field?(@value)
        MiqExpression::Field.parse(@value).arel_attribute
      else
        @value
      end
    end

    def ruby_value
      MiqExpression::Coercer.coerce(value, target.column_type)
    end

    def sql?
      !!arel_attribute
    end

    def arel_attribute
      target.arel_attribute
    end

    def column_type
      target.column_type
    end

    def column
      target.column
    end

    def message_chain
      target.message_chain
    end

    def full_message_chain
      target.full_message_chain
    end

    def ref
      target.ref
    end

    def to_tag
      target.to_tag
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

    def sql?
      sub_expression.sql?
    end
  end

  MiqExpression::Component::After = Class.new(MiqExpression::Component::Leaf)

  class MiqExpression::Component::And < MiqExpression::Component::Composite
    def sql?
      sub_expressions.all?(&:sql?)
    end
  end

  MiqExpression::Component::Before = Class.new(MiqExpression::Component::Leaf)

  class MiqExpression::Component::Checkall < MiqExpression::Component::SingleComposite
    def mode
      "all"
    end
  end

  class MiqExpression::Component::Checkany < MiqExpression::Component::SingleComposite
    def mode
      "any"
    end
  end

  class MiqExpression::Component::Checkcount < MiqExpression::Component::SingleComposite
    def mode
      "count"
    end
  end

  class MiqExpression::Component::Contains < MiqExpression::Component::Leaf
    def self.build(options)
      target = if options["tag"]
                 MiqExpression::Tag.parse(options["tag"])
               else
                 MiqExpression::Field.parse(options["field"])
               end
      new(target, options["value"])
    end

    def sql?
      case target
      when MiqExpression::Tag
        true
      when MiqExpression::Field
        return false unless target.associations.one?
        return false unless target.reflections.first.macro.in?([:has_many, :has_one])
        return false if target.reflections.first.options.key?(:as)
        super
      else
        false
      end
    end
  end

  MiqExpression::Component::EndsWith = Class.new(MiqExpression::Component::Leaf)

  class MiqExpression::Component::Equal < MiqExpression::Component::Leaf
    def ruby_operator
      "=="
    end
  end

  class MiqExpression::Component::Find < MiqExpression::Component::Base
    def self.build(options)
      check = %w(checkall checkany checkcount).detect { |c| options.include?(c) }
      raise _("expression malformed,  must contain one of 'checkall', 'checkany', 'checkcount'") unless check

      new(MiqExpression::Component.build(options.slice(check)),
          MiqExpression::Component.build(options.slice("search")))
    end

    attr_reader :check, :search

    def initialize(check, search)
      @check = check
      @search = search
    end
  end

  class MiqExpression::Component::From < MiqExpression::Component::Leaf
    def ruby_operator
      %w(>= <=)
    end

    def start_value(timezone)
      MiqExpression::RelativeDatetime.normalize(value[0], timezone, "beginning", target.date?)
    end

    def end_value(timezone)
      MiqExpression::RelativeDatetime.normalize(value[1], timezone, "end", target.date?)
    end
  end

  class MiqExpression::Component::GreaterThan < MiqExpression::Component::Leaf
    def ruby_operator
      ">"
    end
  end

  class MiqExpression::Component::GreaterThanOrEqual < MiqExpression::Component::Leaf
    def ruby_operator
      ">="
    end
  end

  MiqExpression::Component::IncludesAll = Class.new(MiqExpression::Component::Leaf)
  MiqExpression::Component::IncludesAny = Class.new(MiqExpression::Component::Leaf)
  MiqExpression::Component::IncludesOnly = Class.new(MiqExpression::Component::Leaf)

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

  class MiqExpression::Component::IsNotNull < MiqExpression::Component::Leaf
    def ruby_operator
      "!="
    end
  end

  MiqExpression::Component::IsNull = Class.new(MiqExpression::Component::Leaf)
  MiqExpression::Component::KeyExists = Class.new(MiqExpression::Component::Leaf)

  class MiqExpression::Component::LessThan < MiqExpression::Component::Leaf
    def ruby_operator
      "<"
    end
  end

  class MiqExpression::Component::LessThanOrEqual < MiqExpression::Component::Leaf
    def ruby_operator
      "<="
    end
  end

  MiqExpression::Component::Like = Class.new(MiqExpression::Component::Leaf)
  MiqExpression::Component::LimitedTo = Class.new(MiqExpression::Component::Leaf)
  MiqExpression::Component::Not = Class.new(MiqExpression::Component::SingleComposite)
  MiqExpression::Component::NotEqual = Class.new(MiqExpression::Component::Leaf)

  class MiqExpression::Component::NotEqual < MiqExpression::Component::Leaf
    def ruby_operator
      "!="
    end
  end

  MiqExpression::Component::NotLike = Class.new(MiqExpression::Component::Leaf)

  class MiqExpression::Component::Or < MiqExpression::Component::Composite
    def sql?
      sub_expressions.any?(&:sql?)
    end
  end

  class MiqExpression::Component::RegularExpressionMatches < MiqExpression::Component::Leaf
    def value
      MiqExpression::RegularExpressionSanitizer.sanitize(@value)
    end

    def ruby_operator
      "=~"
    end

    def sql?
      false
    end
  end

  class MiqExpression::Component::RegularExpressionDoesNotMatch < MiqExpression::Component::Leaf
    def value
      MiqExpression::RegularExpressionSanitizer.sanitize(@value)
    end

    def ruby_operator
      "!~"
    end

    def sql?
      false
    end
  end

  MiqExpression::Component::Search = Class.new(MiqExpression::Component::SingleComposite)
  MiqExpression::Component::StartsWith = Class.new(MiqExpression::Component::Leaf)
  MiqExpression::Component::ValueExists = Class.new(MiqExpression::Component::Leaf)

  TYPES = {
    "!"                                 => Not,
    "!="                                => NotEqual,
    "<"                                 => LessThan,
    "<="                                => LessThanOrEqual,
    "="                                 => Equal,
    ">"                                 => GreaterThan,
    ">="                                => GreaterThanOrEqual,
    "after"                             => After,
    "and"                               => And,
    "before"                            => Before,
    "checkall"                          => Checkall,
    "checkany"                          => Checkany,
    "checkcount"                        => Checkcount,
    "contains"                          => Contains,
    "ends with"                         => EndsWith,
    "equal"                             => Equal,
    "find"                              => MiqExpression::Component::Find,
    "from"                              => From,
    "includes"                          => Like,
    "includes all"                      => IncludesAll,
    "includes any"                      => IncludesAny,
    "includes only"                     => IncludesOnly,
    "is empty"                          => IsEmpty,
    "is not empty"                      => IsNotEmpty,
    "is not null"                       => IsNotNull,
    "is null"                           => IsNull,
    "is"                                => Is,
    "key exists"                        => KeyExists,
    "like"                              => Like,
    "limited to"                        => LimitedTo,
    "not like"                          => NotLike,
    "not"                               => Not,
    "or"                                => Or,
    "regular expression matches"        => RegularExpressionMatches,
    "regular expression does not match" => RegularExpressionDoesNotMatch,
    "search"                            => Search,
    "starts with"                       => StartsWith,
    "value exists"                      => ValueExists
  }.freeze

  def self.for_operator(operator)
    TYPES[operator.downcase] or raise _("operator '%{operator_name}' is not supported") % {:operator_name => operator}
  end

  def self.build(expression)
    operator = expression.keys.first
    for_operator(operator).build(expression[operator])
  end
end
