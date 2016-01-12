Gem::Specification.new do |s|
  s.name = 'cows_bulls_arena'
  s.version = '1.0.0'
  s.licenses = ['MIT']
  s.summary = 'Project for Ruby course at FMI. A multiplayer guessing game.'
  s.description = 'Project for Ruby course at FMI. A multiplayer guessing game.'
  s.authors = ['Boyko Karadzhov']
  s.email = 'bokovskii@gmail.com'
  s.files = Dir['lib/   *.rb'] + Dir['bin/*']
  s.files += Dir['[A-Z]*'] + Dir['spec/**/*']
  s.homepage = 'https://github.com/Boyko-Karadzhov/fmi-rb-cb-arena'

  s.add_development_dependency 'bundler', '~> 1.11', '=> 1.11.2'
  s.add_development_dependency 'rake', '~> 10.4', '>= 10.4.2'
  s.add_development_dependency 'rspec', '~> 3.3', '>= 3.3.2'
  s.add_development_dependency 'rubocop'
end
