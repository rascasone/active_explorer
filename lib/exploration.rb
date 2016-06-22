require 'writer'
require 'painter'
require 'config'

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
    #
    # @param depth [Integer]
    #   How deep into the subobjects should the explorere go. Depth 1 is only direct children. Depth 0 returns no children.
    #
    def initialize(object, depth: 5, class_filter: nil, attribute_filter: nil, attribute_limit: nil, association_filter: nil, parent_object: nil)
      raise TypeError, "Parameter 'class_filter' must be Array or Hash but is #{class_filter.class}." unless class_filter.nil? || class_filter.is_a?(Array) || class_filter.is_a?(Hash)
      raise TypeError, "Parameter 'association_filter' must be Array but is #{association_filter.class}." unless association_filter.nil? || association_filter.is_a?(Array)
      raise TypeError, "Parameter 'association_filter' must only contain values #{ASSOCIATION_FILTER_VALUES.to_s[1..-2]}." unless association_filter.nil? || association_filter.empty? || (association_filter & ASSOCIATION_FILTER_VALUES).any?

      @object = object
      @depth = depth
      @parent_object = parent_object

      @attribute_limit = attribute_limit || ActiveExplorer::Config.attribute_limit
      @attribute_filter = attribute_filter || ActiveExplorer::Config.attribute_filter

      @hash = { class_name: make_safe(@object.class.name),
                attributes: attributes }

      unless @depth.zero?
        @class_filter = class_filter || ActiveExplorer::Config.class_filter
        @class_filter = { show: @class_filter } if @class_filter.is_a?(Array)

        if @class_filter
          [:show, :ignore].each do |group|
            @class_filter[group] = @class_filter[group].present? ? each_val_to_s(@class_filter[group]) : []
          end
        end

        @association_filter = association_filter || ActiveExplorer::Config.association_filter
        @association_filter = ASSOCIATION_FILTER_VALUES if @association_filter.present? && @association_filter.include?(:all)

        @associations = associtations(@object, @class_filter, @association_filter)

        subobject_hash = subobjects_hash(@object, @associations)
        @hash[:subobjects] = subobject_hash unless subobject_hash.empty?
      end
    end

    def attributes
      attrs = @object.attributes.symbolize_keys
      attrs = attrs.first(@attribute_limit).to_h if @attribute_limit

      return attrs if @attribute_filter.nil?

      filter = @attribute_filter[@object.class.name.downcase.pluralize.to_sym]

      if filter
        attrs.select { |key| filter.include?(key) }
      else
        attrs
      end
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
      subobjects.present? ? subobjects : nil

    rescue NameError, ActiveRecord::StatementInvalid, ActiveRecord::RecordNotFound => e
      association_type = association.macro
      add_error_hash("#{e.message} in #{association_type} :#{association.name}")
      nil
    end

    def explore(object, parent_object:, association_type:)
      association_filter = if !@association_filter.nil? && @association_filter.any?
                             @association_filter
                           elsif association_type == :belongs_to
                             [:belongs_to]
                           else
                             [:has_many, :has_one]
                           end

      Exploration.new object,
                      depth: @depth - 1,
                      class_filter: @class_filter,
                      attribute_filter: @attribute_filter,
                      attribute_limit: @attribute_limit,
                      association_filter: association_filter,
                      parent_object: parent_object
    end

    def associtations(object, class_filter, association_filter)
      associations = object.class.reflections.collect do |reflection|
        reflection.second
      end

      if !association_filter.nil? && association_filter.any? && !association_filter.include?(:all)
        associations.select! do |association|
          association_filter.include? association_type(association)
        end
      end

      if class_filter
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
      @hash[:attributes] = attributes

      @hash[:error_message] = "Error in #{@object.class.name}(#{@object.id}): #{message}"
    end

    def association_type(association)
      association.macro
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