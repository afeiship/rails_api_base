class UserBlueprint < Blueprinter::Base
  identifier :id
  fields :name, :email, :created_at

  # Dynamic fields for field selection
  dynamic_fields = [:posts]

  dynamic_fields.each do |field_name|
    field field_name, if: ->(_, model, options) {
      Array(options[:fields]).include?(field_name)
    }
  end
end
