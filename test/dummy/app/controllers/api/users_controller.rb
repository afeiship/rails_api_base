module Api
  class UsersController < RailsApiBase::BaseController
    blueprint_options_default :fields

    supports_query(
      pagination: { enabled: true, default_per: 10, max_per: 50 },
      sorting: { enabled: true, allowed_fields: [:id, :name, :email, :created_at] },
      searching: { enabled: true, searchable_fields: [:name, :email] }
    )

    private

    def collection
      User.includes(:posts)
    end

    def resource_params
      params.require(:user).permit(:name, :email)
    end
  end
end
