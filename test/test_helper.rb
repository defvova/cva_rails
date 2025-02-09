# frozen_string_literal: true

require "simplecov"

require "minitest/autorun"
require "cva_rails"

# Source: https://github.com/rails/record_tag_helper/blob/master/test/test_helper.rb
module RenderERBUtils
  def render_erb(string)
    @virtual_path = nil

    template = ActionView::Template.new(
      string.strip,
      "test template",
      ActionView::Template::Handlers::ERB,
      format: :html, locals: []
    )

    render(template:)
  end
end
