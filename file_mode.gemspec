Gem::Specification.new do |s|
  s.authors = ['Martin Carpenter']
  s.date = Time.now.strftime('%Y-%m-%d')
  s.description = 'Provides class methods and mixin to convert UNIX file permissions between long listing and 4-digit octal formats'
  s.email = 'mcarpenter@free.fr'
  s.extra_rdoc_files = ['LICENSE', 'Rakefile', 'README.rdoc']
  s.files = FileList['examples/**/*', 'lib/**/*', 'test/**/*'].to_a
  s.has_rdoc = true
  s.homepage = 'http://github.com/mcarpenter/file_mode'
  s.licenses = ['BSD']
  s.name = 'file_mode'
  s.platform = Gem::Platform::RUBY
  s.require_path = 'lib'
  s.rubyforge_project = nil
  s.summary = 'Convert UNIX file permissions'
  s.test_files = FileList["{test}/**/test_*.rb"].to_a
  s.version = '0.0.1'
end

