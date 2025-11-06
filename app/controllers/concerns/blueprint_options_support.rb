# app/controllers/concerns/blueprint_options_support.rb
module BlueprintOptionsSupport
  extend ActiveSupport::Concern

  included do
    # 声明 DSL
    class << self
      def blueprint_options_default(*modes)
        @blueprint_modes = modes
      end

      def blueprint_modes
        # 支持继承：如果子类没定义，就继承父类的设置
        if instance_variable_defined?(:@blueprint_modes)
          @blueprint_modes
        else
          superclass.respond_to?(:blueprint_modes) ? superclass.blueprint_modes : []
        end
      end
    end
  end

  # === 主入口 ===
  def blueprint_options
    opts = {}
    self.class.blueprint_modes.each do |mode|
      method_name = "blueprint_options_for_#{mode}"
      if respond_to?(method_name, true)
        opts.merge!(send(method_name))
      else
        Rails.logger.warn("[BlueprintOptionsSupport] Unknown mode: #{mode}")
      end
    end
    opts
  end

  private

  # === 模式定义区 ===
  def blueprint_options_for_defaults
    { params: params }
  end

  def blueprint_options_for_fields
    return {} unless params[:fields].present?

    fields = params[:fields].split(",").map(&:strip).map(&:to_sym)
    { fields: fields }
  end

  # 你未来还可以轻松扩展：
  # def blueprint_options_for_locale
  #   { locale: I18n.locale }
  # end
end
