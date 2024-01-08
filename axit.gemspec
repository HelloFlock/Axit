Gem::Specification.new do |s|
  s.name        = 'axit'
  s.version     = '0.1.0'
  s.summary     = "Authorize-or-Exit"
  s.description = "Simple RBAC for Rails apps"
  s.authors     = ["Akshay Khole"]
  s.email       = 'akshay@helloflock.com'
  s.files       = ["lib/axit.rb"]
  s.licenses    = ['MIT']
  s.homepage = 'https://github.com/HelloFlock'
  s.add_runtime_dependency('zeitwerk', '~> 2.2')
end
