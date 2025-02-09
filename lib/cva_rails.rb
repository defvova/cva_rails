# frozen_string_literal: true

require "active_support"
require "action_view"
require "clsx-rails"

require_relative "cva/version"
require_relative "cva/helper"

# :nodoc:
module Cva
  ActiveSupport.on_load(:action_view) { include Helper }
end
