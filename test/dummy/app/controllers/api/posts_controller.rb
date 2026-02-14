module Api
  class PostsController < RailsApiBase::BaseController
    # Enable field selection via ?fields=title,user
    blueprint_options_default :fields

    # Configure query features
    supports_query(
      pagination: { enabled: true, default_per: 10, max_per: 100 },
      sorting: { enabled: true, allowed_fields: [:id, :title, :status, :views, :created_at] },
      searching: { enabled: true, searchable_fields: [:title, :content] },
      filtering: { enabled: true, filterable_fields: [:status, :user_id, :views] }
    )

    private

    def collection
      # Prevent N+1 queries
      Post.includes(:user)
    end

    def resource_params
      params.require(:post).permit(:title, :content, :status, :views, :user_id)
    end
  end
end
