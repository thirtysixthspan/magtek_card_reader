Gem::Specification.new do |s|
  s.name        = 'magtek_card_reader'
  s.version     = '1.0.2'
  s.date        = '2019-06-12'
  s.homepage    = 'http://github.com/thirtysixthspan/magtek_card_reader'
  s.summary     = 'Magtek Credit Card Reader Library'
  s.description = 'Provides a convenient wrapper around libusb to read credit cards with a Magtek Credit Card Reader.'
  s.authors     = ['Derrick Parkhurst']
  s.email       = 'derrick.parkhurst@gmail.com'
  s.platform    = Gem::Platform::RUBY
  s.files       = Dir.glob('{lib,bin}/**/**/*')
  s.executables = Dir.glob('bin/*').map { |f| f.gsub(/bin\//,'') }
  s.require_paths = ['lib']
  s.add_dependency 'libusb', '~>0.6.4'
end

