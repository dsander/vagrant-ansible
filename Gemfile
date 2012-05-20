source :rubygems
gem 'vagrant'

group :test, :development do 
  gem 'rspec'
  gem 'rspec-mocks'
  gem 'simplecov', :require => false
  gem 'rake'
  platforms :mri do
    gem 'hoe'
    gem 'hoe-git'
    gem 'hoe-gemspec'
    gem 'hoe-bundler'
    gem 'ZenTest'
    #gem 'autotest-fsevent'
  end
end

