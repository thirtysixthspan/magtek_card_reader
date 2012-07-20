require 'rspec'
require 'gibberish'

RSpec.configure do |config|
  config.before :each do |x|
    puts "\n\nTest #{x.example.metadata[:example_group][:full_description]}: #{x.example.description}"
  end
end

