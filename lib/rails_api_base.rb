# lib/rails_api_base.rb
require "blueprinter"
require "rails_api_base/engine"

module RailsApiBase
  # 可选：提供便捷引用
  def self.base_controller
    RailsApiBase::BaseController
  end
end