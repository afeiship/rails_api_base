# rails_api_base
> Standardized JSON API base controller for Rails with Blueprinter support.

## Features
- Unified response format: `{ code, msg, data }`
- Field selection via `?fields=title,user`
- Auto Blueprinter integration (`PostBlueprint`)
- CRUD scaffolding (index/show/create/update/destroy)
- Customizable response codes
- N+1 safe (with proper `includes` in controller)

## Installation
Add to your Gemfile:

```ruby
gem 'rails_api_base'
gem 'blueprinter'
```

## Usage
-./app/blueprints/post_blueprint.rb
-./app/controllers/posts_controller.rb

```rb
# blueprint file - optimize version(dynamic_fields)
class PostBlueprint < Blueprinter::Base
  identifier :id
  fields :title, :content

  # === 动态注册可选字段 ===
  dynamic_fields = [:user, :tags]

  dynamic_fields.each do |field_name|
    field field_name, if: ->(_, model, options) {
      Array(options[:fields]).include?(field_name)
    }
  end
end

# posts controller
class PostsController < RailsApiBase::BaseController
  blueprint_options_default :fields

  private
  def collection
    Post.includes(:user, :tags)
        .page(params[:page])
        .per(params[:size] || 10)
  end

  def post_params
    params.require(:post).permit(:title, :content)
  end
end
```