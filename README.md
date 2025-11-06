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