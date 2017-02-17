class MiqExpression::Field
  FIELD_REGEX = /
(?<model_name>([[:upper:]][[:alnum:]]*(::)?)+)
\.?(?<associations>[a-z_\.]+)*
-(?<column>[a-z]+(_[[:alnum:]]+)*)
/x

  ParseError = Class.new(StandardError)

  def self.parse(field)
    match = FIELD_REGEX.match(field) or return
    model = match[:model_name].safe_constantize or return
    new(model, match[:associations].to_s.split("."), match[:column])
  end

  def self.parse!(field)
    parse(field) or raise ParseError, field
  end

  attr_reader :model, :associations, :column

  def initialize(model, associations, column)
    @model = model
    @associations = associations
    @column = column
  end

  def message_chain
    [*associations, column].join(".")
  end

  def full_message_chain
    # "#{model.name}.#{message_chain}"
    [model.name, *associations, column].last(2).join(".")
  end

  def ref
    model.name.downcase
  end

  def to_tag
    ["/virtual", *associations, column].join("/")
  end

  def date?
    column_type == :date
  end

  def self.is_field?(field)
    if field.kind_of?(String)
      match = FIELD_REGEX.match(field)
      match.present? && match[:model_name].safe_constantize.present?
    end
  end

  def datetime?
    column_type == :datetime
  end

  def string?
    column_type == :string
  end

  def numeric?
    [:fixnum, :integer, :float].include?(column_type)
  end

  def attribute_supported_by_sql?
    !custom_attribute_column? && target.attribute_supported_by_sql?(column)
  end

  def plural?
    return false if reflections.empty?
    [:has_many, :has_and_belongs_to_many].include?(reflections.last.macro)
  end

  def custom_attribute_column?
    column.include?(CustomAttributeMixin::CUSTOM_ATTRIBUTES_PREFIX)
  end

  def reflections
    klass = model
    associations.collect do |association|
      klass.reflection_with_virtual(association).tap do |reflection|
        raise ArgumentError, "One or more associations are invalid: #{associations.join(", ")}" unless reflection
        klass = reflection.klass
      end
    end
  end

  def target
    if associations.none?
      model
    else
      reflections.last.klass
    end
  end

  def column_type
    if custom_attribute_column?
      CustomAttribute.where(:name => custom_attribute_column_name, :resource_type => model.to_s).first.try(:value_type)
    else
      target.type_for_attribute(column).type
    end
  end

  def virtual_attribute?
    target.virtual_attribute?(column)
  end

  def sub_type
    MiqReport::Formats.sub_type(column.to_sym) || column_type
  end

  def arel_attribute
    target.arel_attribute(column)
  end

  def arel_table
    target.arel_table
  end

  def sql?
    # => false if operand is from a virtual reflection
    return false if virtual_reflection?
    # return false unless attribute_supported_by_sql?(field)

    # => false if excluded by special case defined in preprocess options
    # return false if self.field_excluded_by_preprocess_options?(field)

    !Field.is_field?(value) || Field.parse(value).attribute_supported_by_sql?
  end

  private

  def virtual_reflection?
    reflections.any? { |model| model.virtual_reflection? }
  end

  def custom_attribute_column_name
    column.gsub(CustomAttributeMixin::CUSTOM_ATTRIBUTES_PREFIX, "")
  end
end
