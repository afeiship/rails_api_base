# app/controllers/concerns/rails_api_base/queryable.rb
module Queryable
  extend ActiveSupport::Concern

  DEFAULT_CONFIG = {
    pagination: { enabled: false, page_param: :page, per_param: :size, default_per: 10, max_per: 100 },
    sorting:    { enabled: false, sort_param: :sort, default_direction: :asc, allowed_fields: [] },
    searching:  { enabled: false, search_param: :q, searchable_fields: [] },
    filtering:  { enabled: false, filter_param: :filter, filterable_fields: [] }
  }.freeze

  class_methods do
    def supports_query(user_config = {})
      config = DEFAULT_CONFIG.deep_dup
      user_config.each do |key, value|
        if config.key?(key) && value.is_a?(Hash)
          config[key].merge!(value)
        else
          config[key] = value
        end
      end

      # 定义实例方法，供 InstanceMethods 使用
      define_method(:query_config) { config }

      include InstanceMethods
    end
  end

  module InstanceMethods
    def apply_query(scope)
      scope = apply_filtering(scope)    if query_config[:filtering][:enabled]
      scope = apply_searching(scope)    if query_config[:searching][:enabled]
      scope = apply_sorting(scope)      if query_config[:sorting][:enabled]
      scope = apply_pagination(scope)   if query_config[:pagination][:enabled]
      scope
    end

    private

    def apply_pagination(scope)
      config = query_config[:pagination]

      # page 至少为 1
      page = [params[config[:page_param]].to_i, 1].max

      # per: 如果 <=0，用默认值；否则限制在 [1, max_per]
      per_input = params[config[:per_param]].to_i
      per = if per_input <= 0
              config[:default_per]
            else
              [per_input, config[:max_per]].min
            end
      per = [per, 1].max

      scope.page(page).per(per)
    end

    def apply_sorting(scope)
      config = query_config[:sorting]
      sort_param = params[config[:sort_param]]
      return scope unless sort_param.present?

      direction = sort_param.start_with?('-') ? :desc : :asc
      field = sort_param.delete_prefix('-').to_sym

      if config[:allowed_fields].empty? || config[:allowed_fields].include?(field)
        scope.order(Arel.sql(sanitize_sql_order(field, direction)))
      else
        scope
      end
    end

    def sanitize_sql_order(field, direction)
      direction = %i[asc desc].include?(direction) ? direction : :asc
      "#{connection.quote_column_name(field)} #{direction}"
    end

    def apply_searching(scope)
      config = query_config[:searching]
      term = params[config[:search_param]]&.strip
      return scope unless term.present?

      searchable_fields = config[:searchable_fields]
      return scope if searchable_fields.empty?

      terms = Array.new(searchable_fields.size, "%#{term}%")
      conditions = searchable_fields.map do |f|
        "LOWER(#{connection.quote_column_name(f)}) LIKE LOWER(?)"
      end.join(' OR ')
      scope.where(conditions, *terms)
    end

    def apply_filtering(scope)
      config = query_config[:filtering]
      filters = params[config[:filter_param]] || {}
      return scope if filters.empty?

      filterable_fields = config[:filterable_fields].map(&:to_s)
      filters = filters.slice(*filterable_fields)

      filters.inject(scope) do |s, (field, value)|
        if value.is_a?(Hash)
          op = value.keys.first&.to_sym
          val = value.values.first
          apply_filter_operation(s, field, op, val)
        else
          s.where("#{connection.quote_column_name(field)} = ?", val_or_array(value))
        end
      end
    end

    def apply_filter_operation(scope, field, op, value)
      quoted = connection.quote_column_name(field)
      case op
      when :eq  then scope.where("#{quoted} = ?", val_or_array(value))
      when :neq then scope.where("#{quoted} != ?", val_or_array(value))
      when :gt  then scope.where("#{quoted} > ?", value)
      when :gte then scope.where("#{quoted} >= ?", value)
      when :lt  then scope.where("#{quoted} < ?", value)
      when :lte then scope.where("#{quoted} <= ?", value)
      when :in  then scope.where(quoted => Array(value))
      when :nin then scope.where.not(quoted => Array(value))
      else scope
      end
    end

    def val_or_array(val)
      return val unless val.is_a?(String) && val.include?(',')
      val.split(',').map(&:strip)
    end
  end
end
