namespace "gem" do

  task :build do
    system('gem build magtek_card_reader.gemspec')
  end

  task :install => ["gem:build"] do
    system('gem install magtek_card_reader*.gem')
  end

end
