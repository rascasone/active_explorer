require 'writer'
require 'painter'

module ActiveExplorer
  class Exploration
    ASSOCIATION_FILTER_VALUES = [:has_many, :has_one, :belongs_to, :all]

    # Creates new exploration and generates exploration hash.
    #
    # @param association_filter [Array]
    #   Values of array: `:has_many`, `:has_one`, `:belongs_to`, `:all`.
    #   When empty then it "follows previous association" (i.e. uses `:belongs_to` when previous assoc. was `:belongs_to` and
    #   uses `:has_xxx` when previous assoc. was `:has_xxx`). To always follow all associations you must specify
    #   all associations (e.g. uses `ActiveExplorer::Exploration::ASSOCIATION_FILTER_VALUES` as a value).
    #
    # @param class_filter [Array or Hash]
    #   If Array is used then it means to show only those classes in Array.
    #   When Hash is used then it can have these keys:
    #     - `:show` - Shows these classes, ignores at all other classes.
    #     - `:ignore` - Stops processing at these, does not show it and does not go to children. Processing goes back to parent.
    #   Use plural form (e.g. `books`).
    def initialize(object, depth: 5, class_filter: [], association_filter: [], parent_object: nil)
      raise TypeError, "Parameter 'class_filter' must be Array or Hash but is #{class_filter.class}." unless class_filter.is_a?(Array) || class_filter.is_a?(Hash)
      raise TypeError, "Parameter 'association_filter' must be Array but is #{association_filter.class}." unless association_filter.is_a? Array
      raise TypeError, "Parameter 'association_filter' must only contain values #{ASSOCIATION_FILTER_VALUES.to_s[1..-2]}." unless association_filter.empty? || (association_filter & ASSOCIATION_FILTER_VALUES).any?
      raise ArgumentError, "Argument 'max_depth' must be at least 1." if depth <= 0

      @object = object
      @depth = depth
      @parent_object = parent_object

      @class_filter = class_filter.is_a?(Array) ? { show: class_filter } : class_filter

      [:show, :ignore].each do |group|
        @class_filter[group] = @class_filter[group].present? ? each_val_to_s(@class_filter[group]) : []
      end

      @association_filter = association_filter.include?(:all) ? ASSOCIATION_FILTER_VALUES : association_filter
      @associations = associtations(@object, @class_filter, @association_filter)

      @hash = { class_name: make_safe(@object.class.name),
                attributes: @object.attributes.symbolize_keys }

      @hash[:subobjects] = subobjects_hash(@object, @associations)
    end

    def get_hash
      @hash.deep_dup
    end

    def to_console
      Writer.new(self).write
    end

    def to_image(file, origin_as_root: false)
      Painter.new(self, file).paint(origin_as_root: origin_as_root)
    end

    private

    def subobjects_hash(object, associations)
      return [] if @depth == 0

      associations.each_with_object([]) do |association, results|
        case association_type(association)
          when :belongs_to
            subobject = subobjects_from_association(object, association)

            if subobject.present?
              results.push subobject_hash(association, object, subobject) unless is_parent?(subobject)
            end

          when :has_many, :has_one
            subobjects = subobjects_from_association(object, association)

            if subobjects.present?
              subobjects.each do |subobject|
                results.push subobject_hash(association, object, subobject) unless is_parent?(subobject)
              end
            end
        end
      end
    end

    def subobject_hash(association, object, subobject)
      association_type = association_type(association)

      exploration = explore(subobject, parent_object: object, association_type: association_type)

      hash = exploration.get_hash
      hash[:association] = association_type
      hash
    end

    def subobjects_from_association(object, association)
      subobjects = object.send(association.name)
      defined?(subobjects) && subobjects.present? ? subobjects : nil

    rescue NameError, ActiveRecord::StatementInvalid, ActiveRecord::RecordNotFound => e
      association_type = is_has_many_association?(association) ? 'has_many' : 'belongs_to'
      add_error_hash("#{e.message} in #{association_type} :#{association.name}")
      nil
    end

    def explore(object, parent_object:, association_type:)
      association_filter = if @association_filter.any?
                             @association_filter
                           elsif association_type == :belongs_to
                             [:belongs_to]
                           else
                             [:has_many, :has_one]
                           end

      Exploration.new object, depth: @depth - 1, class_filter: @class_filter, association_filter: association_filter, parent_object: parent_object
    end

    def associtations(object, class_filter, association_filter)
      associations = object.class.reflections.collect do |reflection|
        reflection.second
      end

      if association_filter.any? && !association_filter.include?(:all)
        associations.select! do |association|
          association_filter.include? association_type(association)
        end
      end

      if class_filter.any?
        if class_filter[:show].any?
          associations.select! do |association|
            should_show?(association)
          end
        elsif class_filter[:ignore].any?
          associations.reject! do |association|
            should_ignore?(association)
          end
        end
      end

      associations
    end

    def add_error_hash(message)
      @hash[:class_name] = make_safe(@object.class.name)
      @hash[:attributes] = @object.attributes.symbolize_keys

      @hash[:error_message] = "Error in #{@object.class.name}(#{@object.id}): #{message}"
    end

    def association_type(association)
      if association.is_a?(ActiveRecord::Reflection::HasManyReflection)
        :has_many
      elsif association.is_a?(ActiveRecord::Reflection::HasOneReflection)
        :has_one
      elsif association.is_a?(ActiveRecord::Reflection::BelongsToReflection)
        :belongs_to
      end
    end

    def make_short(text)
      text.length < 70 ? text : text[0..70] + " (...)"
    end

    # Replace characters that conflict with DOT language (used in GraphViz).
    # These: `{`, `}`, `<`, `>`, `|`, `\`
    #
    def make_safe(text)
      text.tr('{}<>|\\', '')
    end

    def each_val_to_s(array)
      array.collect { |a| a.to_s }
    end

    def is_belongs_to_association?(association)
      association.is_a?(ActiveRecord::Reflection::BelongsToReflection)
    end

    def is_has_many_association?(association)
      association.is_a?(ActiveRecord::Reflection::HasManyReflection)
    end

    def is_has_one_association?(association)
      association.is_a?(ActiveRecord::Reflection::HasOneReflection)
    end

    def is_parent?(object)
      object === @parent_object
    end

    def should_show?(association)
      @class_filter[:show].include? association.plural_name.to_s
    end

    def should_ignore?(association)
      @class_filter[:ignore].include? association.plural_name.to_s
    end
  end
end