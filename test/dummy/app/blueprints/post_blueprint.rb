class PostBlueprint < Blueprinter::Base
  identifier :id
  fields :title, :content, :status, :views, :created_at, :updated_at

  # Dynamic fields for field selection
  dynamic_fields = [:user, :comments]

  dynamic_fields.each do |field_name|
    field field_name, if: ->(_, model, options) {
      Array(options[:fields]).include?(field_name)
    }
  end
end
