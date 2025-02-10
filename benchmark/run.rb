# frozen_string_literal: true

require "bundler/setup"
require "benchmark/ips"

require "clsx-rails"
require "cva_rails"

@base_classes = "font-semibold borderrounded"
@schema = {
  variants: {
    intent: {
      primary: %w[bg-blue-500 text-white border-transparent],
      secondary: %w[bg-white text-gray-800 border-gray-400]
    },
    size: {
      small: %w[text-sm py-1 px-2],
      medium: %w[text-base py-2 px-4]
    }
  },
  compound_variants: [
    {
      intent: "primary",
      size: "small",
      class: "hover:bg-blue-600"
    },
    {
      intent: "secondary",
      size: "medium",
      class: "uppercase"
    }
  ],
  default_variants: {
    intent: "secondary",
    size: "medium"
  }
}

# :nodoc:
class OriginalComponent
  include Cva::Helper
  cva(@base_classes, @schema)
end

# :nodoc:
module CvaOptimizedModule
  extend ActiveSupport::Concern

  included do
    extend Clsx::Helper
    class_attribute :cva_data
  end

  class_methods do # rubocop:disable Metrics/BlockLength
    def cva(base, schema = {})
      schema = {} if schema.nil?

      validate_type(schema[:variants], Hash, "schema variants")
      validate_type(schema[:compound_variants], Array, "schema compound_variants")
      validate_type(schema[:default_variants], Hash, "schema default_variants")

      self.cva_data = { base:, schema: schema.transform_keys(&:to_sym) }.freeze
    end

    def variants(params = {})
      base_classes = cva_data[:base]
      variant_classes = build_variant_class_names(params)
      compound_classes = build_compound_variant_class_names(params)

      clsx(base_classes, variant_classes, compound_classes, params[:class])
    end

    private

    def build_variant_class_names(params)
      variants = cva_data.dig(:schema, :variants)
      return [] if variants.nil?

      variants.keys.flat_map do |key|
        selected_variant = params.fetch(key, cva_data.dig(:schema, :default_variants, key))
        variants.dig(key, selected_variant&.to_sym)
      end.compact
    end

    def build_compound_variant_class_names(params)
      compound_variants = cva_data.dig(:schema, :compound_variants) || []
      compound_variants.each_with_object([]) do |compound_variant, acc|
        next unless compound_variant.except(:class) <= params

        acc << compound_variant[:class]
      end
    end

    def validate_type(value, expected_type, description)
      return if value.nil? || value.is_a?(expected_type)

      raise ArgumentError,
            "Expected a #{expected_type} for #{description}, but got #{value.class}. " \
            "Please ensure the #{description} is properly formatted."
    end
  end
end

# :nodoc:
class OptimizedComponent
  include CvaOptimizedModule
  cva(@base_classes, @schema)
end

Benchmark.ips do |x|
  x.report("original") { OriginalComponent.variants }
  x.report("optimized") { OptimizedComponent.variants }
  x.compare!
end
