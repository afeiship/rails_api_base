# app/controllers/rails_api_base/base_controller.rb
module RailsApiBase
  class BaseController < ActionController::API
    include BlueprintOptionsSupport
    
    # 默认开启 :defaults 模式
    blueprint_options_default :defaults

    # === 统一成功响应 ===
    def render_success(data, status: :ok, message: "success", code: nil)
      code ||= response_code_for(action_name, status: status)
      render json: { code: code, msg: message,  data: data }, status: status
    end

    # === 统一错误响应 ===
    def render_error(message: "Unprocessable Entity", status: :unprocessable_entity, errors: nil)
      code = response_code_for(action_name, status: status)
      render json: { code: code, msg: message,  errors: errors }, status: status
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
      items = collection
      data = serialize_collection(items)
      render_success(data)
    end

    def show
      data = serialize_resource(resource)
      render_success(data)
    end

    def create
      resource = resource_class.new(resource_params)
      if resource.save
        data = serialize_resource(resource)
        render_success(data, status: :created, message: "Created successfully")
      else
        render_error(message: "Validation failed", errors: resource.errors.full_messages)
      end
    end

    def update
      if resource.update(resource_params)
        data = serialize_resource(resource)
        render_success(data, message: "Updated successfully")
      else
        render_error(message: "Validation failed", errors: resource.errors.full_messages)
      end
    end

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
      raise NotImplementedError, "Subclass must implement ##{controller_name.singularize}_params"
    end
  end
end