# frozen_string_literal: true

require "test_helper"

module Cva
  class TestIntegrationHelper < ActionView::TestCase
    include Cva::Helper

    include RenderERBUtils

    cva(
      ["px-4 py-2", "bg-red-100"],
      {
        variants: { size: { medium: "text-base", small: "text-sm", large: "text-xl" },
                    color: { red: "text-red-100" } },
        compound_variants: [{ size: :medium, class: "w-10" }, { size: :small, class: "w-8" },
                            { color: :red, class: "strong" }],
        default_variants: { size: :large }
      }
    )

    def test_cva_with_default_variants
      expected = %(<div class="px-4 py-2 bg-red-100 text-xl"></div>)
      actual = tag.div class: self.class.variants

      assert_dom_equal expected, actual
    end

    def test_cva_with_variants
      expected = %(<div class="px-4 py-2 bg-red-100 text-base w-10"></div>)
      actual = tag.div class: self.class.variants({ size: :medium })

      assert_dom_equal expected, actual
    end
  end
end
