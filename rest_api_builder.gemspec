Gem::Specification.new do |s|
  s.name        = 'rest_api_builder'
  s.version     = '0.1.1'
  s.summary     = "A simple wrapper for rest-client"
  s.description = "A simple wrapper for rest-client aiming to make creation and testing of API clients easier."
  s.authors     = ["Alexey D"]
  s.email       = 'ord.alwo@gmail.com'
  s.files       = Dir["LICENSE", "README.md", "rest_api_builder.gemspec", "lib/**/*"]
  s.license     = 'MIT'
  s.homepage    = 'https://github.com/alexeyds/rest_api_builder'

  s.add_development_dependency('rubocop', '~> 0.8')
  s.add_development_dependency('webmock', '~> 3.0')

  s.add_dependency('rest-client', '~> 2.0')

  s.required_ruby_version = '>= 2.4.0'
end
