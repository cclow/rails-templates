# run with
# rails new project -T --skip-bundle -m rails-templates/base.rb
#
require File.join(File.dirname(__FILE__), 'archive_helper')

git :init

run 'echo "# rvm current environment : `rvm current`" > .rvmrc'
run 'echo "rvm use `rvm current`" | sed "s/@.*//" > .rvmrc'
run 'rvm rvmrc trust'

remove_file 'doc/README_FOR_APP'
remove_file 'public/index.html'
remove_file 'app/assets/images/rails.png'

run 'cp config/database.yml config/database-sample.yml'
append_file '.gitignore', "config/database.yml\n"

gem 'simple_form'
gem 'slim-rails'

gem 'faker', :group => [:test, :development]
gem 'factory_girl_rails', :group => [:test, :development]
gem 'rspec-rails', :group => [:test, :development ]
gem 'cucumber-rails', :group => [:test, :development ]
gem 'capybara', :group => [:test, :development]
gem 'akephalos', :group => [:test, :development]
gem 'jasmine', :group => [:test, :development ]
gem 'launchy', :group => [:test, :development]
gem 'database_cleaner', :group => [:test, :development]
gem 'guard-rspec', :group => [:test, :development]
gem 'guard-cucumber', :group => [:test, :development]
gem 'shoulda-matchers', :group => [:test, :development]
gem 'rails3-generators', :group => :development
gem 'awesome_print', :group => :development
gem 'rb-fsevent', :require => false, :group => [:test, :development] if RUBY_PLATFORM =~ /darwin/i

append_file '.gitignore', "vendor/ruby\n"
run 'bundle install --path vendor && bundle package'

generate 'simple_form:install'
generate 'cucumber:install'
generate 'rspec:install'
inside 'spec' do
  empty_directory 'routing'
  empty_directory 'support'
end
run 'bundle exec jasmine init'
remove_file 'lib/tasks/jasmine.rake'
run 'bundle exec guard init rspec'
run 'bundle exec guard init cucumber'

# add default layout and home page
archive_copy('base/layout_helper.rb', 'app/helpers/layout_helper.rb')
archive_copy('base/application.html.slim', 'app/views/layouts/application.html.slim')
remove_file 'app/views/layouts/application.html.erb'

initializer 'slim.rb', <<-SLIM
Slim::Engine.set_default_options :pretty => true unless Rails.env == 'production'
SLIM

initializer 'rails3_generators.rb', <<-RAILS3_GEN
Rails.application.config.generators do |g|
  g.test_framework :rspec, :fixture => true, :views => false
  g.fixture_replacement :factory_girl, :dir => 'spec/factories'
  g.template_engine :slim
end
RAILS3_GEN

git :add => "."
git :commit => '-m "Rails 3.1 app with baseline template"'
