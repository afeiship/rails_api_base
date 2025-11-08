# app/controllers/rails_api_base/base_controller.rb
module RailsApiBase
  class BaseController < ActionController::API
    include BlueprintOptionsSupport
    include Queryable

    # 默认开启 :defaults 模式
    blueprint_options_default :defaults

    # === 统一成功响应 ===
    def render_success(data, status: :ok, message: "success", code: nil)
      code ||= response_code_for(action_name, status: status)
      render json: { code: code, msg: message, data: data }, status: status
    end

    # === 统一错误响应 ===
    def render_error(message: "Unprocessable Entity", status: :unprocessable_entity, errors: nil)
      code = response_code_for(action_name, status: status)
      render json: { code: code, msg: message, errors: errors }, status: status
    end

    # === 允许子类自定义响应 code ===
    def response_code_for(action, **context)
      status = context[:status] || :ok
      if status.is_a?(Integer)
        status
      else
        Rack::Utils::SYMBOL_TO_STATUS_CODE.fetch(status, 200)
      end
    end

    # === CRUD 基础动作 ===
    before_action :set_resource, only: %i[show update destroy]

    def index
      result = apply_query_with_meta(collection)
      data = {
        query_config[:meta][:rows_key] => serialize_collection(result[:collection]),
      }
      data.merge!(result[:meta]) if result[:meta]
      render_success(data)
    end

    def show
      data = serialize_resource(resource)
      render_success(data)
    end

    def create
      resource = resource_class.new(resource_params)
      if before_save(resource) && resource.save
        after_save(resource)
        data = serialize_resource(resource)
        render_success(data, status: :created, message: "Created successfully")
      else
        render_error(message: "Validation failed", errors: resource.errors.full_messages)
      end
    end

    def update
      if before_save(resource) && resource.update(resource_params)
        after_save(resource)
        data = serialize_resource(resource)
        render_success(data, message: "Updated successfully")
      else
        render_error(message: "Validation failed", errors: resource.errors.full_messages)
      end
    end

    # === 可选：通用钩子（默认调用 create/update 钩子）===
    def before_save(resource)
      action_name == "create" ? before_create(resource) : before_update(resource)
    end

    def after_save(resource)
      action_name == "create" ? after_create(resource) : after_update(resource)
    end

    # === 子类覆盖这些 ===
    def before_create(resource); true; end
    def after_create(resource); end

    def before_update(resource); true; end
    def after_update(resource); end

    def destroy
      resource.destroy
      render_success(nil, message: "Deleted successfully")
    end

    private

    # === 序列化逻辑 ===
    def serialize_resource(resource)
      bp = blueprint_class
      bp ? bp.render_as_hash(resource, **blueprint_options) : resource.as_json
    end

    def serialize_collection(collection)
      bp = blueprint_class
      bp ? bp.render_as_hash(collection, **blueprint_options) : collection.as_json
    end

    def blueprint_class
      "#{resource_class}Blueprint".constantize
    rescue NameError
      nil
    end

    # === 资源推导 ===
    def resource_class
      controller_name.singularize.classify.constantize
    end

    def resource
      instance_variable_get("@#{controller_name.singularize}")
    end

    def set_resource
      instance_variable_set("@#{controller_name.singularize}", resource_class.find(params[:id]))
    rescue ActiveRecord::RecordNotFound
      render_error(message: "Record not found", status: :not_found)
    end

    def collection
      resource_class.all
    end

    def resource_params
      # raise NotImplementedError, "Subclass must implement ##{controller_name.singularize}_params"
      permitted_params = params.require(controller_name.singularize.underscore.to_sym)
      permitted_params.permit!
    end
  end
end
