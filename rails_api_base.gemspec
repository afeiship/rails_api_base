require_relative "lib/rails_api_base/version"

Gem::Specification.new do |spec|
  spec.name        = "rails_api_base"
  spec.version     = RailsApiBase::VERSION
  spec.authors     = [ "aric.zheng" ]
  spec.email       = [ "1290657123@qq.com" ]
  spec.homepage    = "https://js.work"
  spec.summary     = "Standardized JSON API foundation for Rails apps."
  spec.description = "Standardized JSON API foundation for Rails apps."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/afeiship/rails_api_base"
  spec.metadata["changelog_uri"] = "https://github.com/afeiship/rails_api_base/blob/master/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  # api_core.gemspec
  spec.add_dependency "rails", ">= 6.0"
  spec.add_dependency "blueprinter"   # 核心序列化
  # spec.add_dependency "kaminari"    # 可选：如果你要封装分页
end
