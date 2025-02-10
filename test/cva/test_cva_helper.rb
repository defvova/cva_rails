# frozen_string_literal: true

require "test_helper"

module Cva
  class TestCvaHelper < Minitest::Test
    include Cva::Helper

    def test_when_base_empty_array_and_no_schema_param
      self.class.cva([])

      assert_empty self.class.cva_data[:base]
      assert_empty self.class.cva_data[:schema]
      assert_nil self.class.variants
    end

    def test_when_base_empty_array_and_schema_nil
      self.class.cva([], nil)

      assert_empty self.class.cva_data[:base]
      assert_empty self.class.cva_data[:schema]
      assert_nil self.class.variants
    end

    def test_when_base_empty_array_and_empty_schema
      self.class.cva([], {})

      assert_empty self.class.cva_data[:base]
      assert_empty self.class.cva_data[:schema]
      assert_nil self.class.variants
    end

    def test_when_base_nil_and_empty_schema
      self.class.cva(nil, {})

      assert_nil self.class.cva_data[:base]
      assert_empty self.class.cva_data[:schema]
      assert_nil self.class.variants
    end

    def test_when_base_string_and_empty_schema
      self.class.cva("", {})

      assert_equal "", self.class.cva_data[:base]
      assert_empty self.class.cva_data[:schema]
      assert_nil self.class.variants
    end

    def test_when_base_hash_and_empty_schema
      self.class.cva({}, {})

      assert_empty self.class.cva_data[:base]
      assert_empty self.class.cva_data[:schema]
      assert_nil self.class.variants
    end

    def test_base_with_arbitrary_values_and_no_schema_param
      self.class.cva(["px-4 py-2", "bg-red-100", nil, false, true, 1, 0, {}, []])

      assert_equal ["px-4 py-2", "bg-red-100", nil, false, true, 1, 0, {}, []], self.class.cva_data[:base]
      assert_empty self.class.cva_data[:schema]
      assert_equal "px-4 py-2 bg-red-100 1 0", self.class.variants
    end

    def test_when_schema_structure_invalid # rubocop:disable Metrics
      assert_raises(ArgumentError) { self.class.cva }
      assert_raises(ArgumentError) { self.class.cva(["px-4"], { variants: [] }) }
      assert_raises(ArgumentError) { self.class.cva(["px-4"], { compound_variants: {} }) }
      assert_raises(ArgumentError) { self.class.cva(["px-4"], { default_variants: [] }) }
      assert_raises(ArgumentError) { self.class.cva(["px-4"], { variants: [], compound_variants: {} }) }
      assert_raises(ArgumentError) { self.class.cva(["px-4"], { variants: {}, default_variants: [] }) }
      assert_raises(ArgumentError) { self.class.cva(["px-4"], { compound_variants: {}, default_variants: [] }) }
    end

    def test_schema_with_variants
      self.class.cva("px-4 py-2 bg-red-100",
                     { variants: { size: { medium: "text-base", small: "text-sm" } } })

      assert_equal "px-4 py-2 bg-red-100 text-base", self.class.variants({ size: :medium })
      assert_equal "px-4 py-2 bg-red-100 text-sm", self.class.variants({ size: :small })
    end

    def test_schema_with_default_variants
      self.class.cva(
        ["px-4 py-2", "bg-red-100"],
        {
          variants: { size: { medium: "text-base", small: "text-sm" } },
          default_variants: { size: :medium }
        }
      )

      assert_equal "px-4 py-2 bg-red-100 text-base", self.class.variants
    end

    def test_schema_with_compound_variants
      self.class.cva(
        ["px-4 py-2", "bg-red-100"],
        {
          variants: { size: { medium: "text-base", small: "text-sm" } },
          compound_variants: [{ size: :medium, class: "w-10" }]
        }
      )

      assert_equal "px-4 py-2 bg-red-100 text-sm", self.class.variants({ size: :small })
      assert_equal "px-4 py-2 bg-red-100 text-base w-10", self.class.variants({ size: :medium })
    end

    def test_schema_with_arbitrary_variants # rubocop:disable Metrics/MethodLength
      self.class.cva(
        ["px-4 py-2", "bg-red-100"],
        {
          variants: { size: { medium: "text-base", small: "text-sm", large: "text-xl" },
                      color: { red: "text-red-100" } },
          compound_variants: [{ size: :medium, class: "w-10" }, { size: :small, class: "w-8" },
                              { color: :red, class: "strong" }],
          default_variants: { size: :large }
        }
      )

      assert_equal "px-4 py-2 bg-red-100 text-xl", self.class.variants
      assert_equal "px-4 py-2 bg-red-100 text-sm w-8", self.class.variants({ size: :small })
      assert_equal "px-4 py-2 bg-red-100 text-base w-10", self.class.variants({ size: :medium })
    end
  end
end
