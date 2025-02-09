# frozen_string_literal: true

module Cva
  # This module provides functionality for managing variants
  # and class names dynamically based on a schema and parameters.
  #
  module Helper
    extend ActiveSupport::Concern

    included do
      extend Clsx::Helper
      class_attribute :cva_data
    end

    class_methods do # rubocop:disable Metrics/BlockLength
      # Defines the base class names and variant schema for a given class.
      # This data is shared through the class and
      # can be accessed to build variant-specific class names dynamically.
      #
      # @param base [Array<String>] Base class names applied to the object/component.
      # @param schema [Hash] Schema for defining variants, default variants, and compound variants.
      #
      # @return [void]
      #
      # @example
      #   class Button
      #     include Cva::Helper
      #
      #     cva(['px-4', 'py-2 bg-red-100'], {
      #       variants: {
      #         size: {
      #           small: ["text-sm", "py-1", "px-2"],
      #           medium: ["text-base", "h-4"]
      #         }
      #       },
      #       compound_variants: [
      #         {
      #           size: :medium,
      #           class: "hover:bg-blue-100"
      #         }
      #       ],
      #       default_variants: {
      #         size: :small
      #       }
      #     })
      #   end
      #
      def cva(base, schema = {})
        schema = {} if schema.nil?

        validate_type(schema[:variants], Hash, "schema variants")
        validate_type(schema[:compound_variants], Array, "schema compound_variants")
        validate_type(schema[:default_variants], Hash, "schema default_variants")

        self.cva_data = { base:, schema: schema.transform_keys(&:to_sym) }.freeze
      end

      # Builds a variants of class names based on the given parameters,
      # including base classes, variant-specific classes, and compound variant classes.
      #
      # @param params [Hash<Symbol, String | Symbol>] A hash of user-specified variants and an optional custom class.
      #
      # @return [Array<String>] A combined array of class names based on the base, variant, and compound rules.
      #
      # **Expected Keys in params**
      #   - Keys matching those defined in variants schema.
      #   - :class (Optional) – Custom class to be included.
      #
      # @example
      #   class Button
      #     include Cva::Helper
      #
      #     cva(...)
      #   end
      #
      #   # show.html.erb
      #   <%= link_to 'Button', '#', class: Button.variants({ size: :medium, class: 'w-10' }) %>
      #
      #   # output:
      #     <a href='#' class="px-4 py-2 bg-red-100 text-base h-4 w-10">Button</a>
      #
      def variants(params = {})
        base_classes = cva_data[:base]
        variant_classes = build_variant_class_names(params)
        compound_classes = build_compound_variant_class_names(params)

        clsx(base_classes, variant_classes, compound_classes, params[:class])
      end

      private

      # Generates an array of class names based on individual variant keys.
      #
      # @param params [Hash<Symbol, String | Symbol>] Parameters specifying which variants to apply.
      #
      # @return [Array<String>] Class names associated with specified or default variants.
      #
      def build_variant_class_names(params)
        variants = cva_data.dig(:schema, :variants)
        return [] if variants.nil?

        variants.keys.flat_map do |key|
          selected_variant = params.fetch(key, cva_data.dig(:schema, :default_variants, key))
          variants.dig(key, selected_variant&.to_sym)
        end.compact
      end

      # Generates an array of class names based on compound variant rules
      # if the conditions match the given parameters.
      #
      # @param params [Hash<Symbol, String | Symbol>] Parameters specifying variant values.
      #
      # @return [Array<String>] Class names for matching compound variants.
      #
      def build_compound_variant_class_names(params)
        compound_variants = cva_data.dig(:schema, :compound_variants) || []
        compound_variants.each_with_object([]) do |compound_variant, acc|
          next unless compound_variant.except(:class) <= params

          acc << compound_variant[:class]
        end
      end

      # Validates the type of a given value, raising an error if the type does not match the expected type.
      #
      # @param value [Object] The value to be validated. Can be any object, including `nil`.
      # @param expected_type [Class] The expected class/type of the value (e.g., `Hash`, `Array`, `String`).
      # @param description [String] A description of the value being validated, used in the error message.
      #
      # @raise [ArgumentError] If the value is not `nil` and does not match the expected type.
      #
      def validate_type(value, expected_type, description)
        return if value.nil? || value.is_a?(expected_type)

        raise ArgumentError,
              "Expected a #{expected_type} for #{description}, but got #{value.class}. " \
              "Please ensure the #{description} is properly formatted."
      end
    end
  end
end
