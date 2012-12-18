Gem::Specification.new do |s|
  s.name        = 'eloqua_api'
  s.version     = '0.0.5'
  s.date        = '2012-10-12'
  s.summary     = "Ruby Eloqua API Wrapper"
  s.description = "Convenience wrapper for Eloqua REST and Bulk APIs"
  s.authors     = ["Nader Akhnoukh"]
  s.email       = 'nader@kapost.com'
  s.files        = Dir['lib/**/*.rb']
  s.require_paths = ['lib']
  s.homepage    =   'http://github.com/kapost/eloqua_api'
  s.licenses = ['MIT']
  s.add_dependency 'json'
end