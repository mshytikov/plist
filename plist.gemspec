Gem::Specification.new do |s|
  s.name = 'plist'
  s.version = '3.1.0'
  s.summary = 'Plist for ruby'
  s.description = 'All-purpose Property List manipulation library'

  s.required_ruby_version     = '>= 1.8.7'
  s.required_rubygems_version = '>= 1.3.5'

  s.authors           = ['Ben Bleything', 'Patrick May']
  s.homepage          = 'http://plist.rubyforge.org/'

  s.extra_rdoc_files = %w(README.rdoc)
  s.files = %w(CHANGELOG LICENSE Rakefile README.rdoc) + Dir['lib/**/*.rb'] + Dir['test/**/*.rb']
end
