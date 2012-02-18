# run with
# rails new project -T --skip-bundle -m rails-templates/base.rb
#
require File.join(File.dirname(__FILE__), 'archive_helper')

git :init

# Need to do this before call the template since
# doing a run "rvm ..." does not change the rvm gemset
#
# run "rvm gemset create #{app_name}"
# run "rvm gemset use #{app_name}"
#
ruby_gemset = `rvm current`.strip

create_file ".rvmrc", "rvm use #{ruby_gemset}"

# remove_file 'doc/README_FOR_APP'
# remove_file 'public/index.html'
# remove_file 'app/assets/images/rails.png'

run 'cp config/database.yml config/database-sample.yml'
archive_copy('base/gitignore', '.gitignore')

append_file 'Gemfile', <<-GEMFILE
gem 'simple_form'
gem 'haml-rails'
gem 'modernizr-rails'

group :development do
  gem 'awesome_print'
  gem 'pry-rails'   # use pry for rails console
end

group :test, :development do
  gem 'faker'
  gem 'factory_girl_rails'
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'capybara'
  gem 'launchy'
  gem 'database_cleaner'
  gem 'guard-bundler'
  gem 'guard-migrate'
  gem 'spork'
  gem 'guard-spork'
  gem 'guard-rspec'
  gem 'rb-fsevent', require: false if RUBY_PLATFORM =~ /darwin/i
  gem 'growl' if RUBY_PLATFORM =~ /darwin/i
end
GEMFILE

run 'bundle install'

generate 'simple_form:install'
generate 'rspec:install'
inside 'spec' do
  empty_directory 'routing'
  empty_directory 'support'
  empty_directory 'requests'
end
inject_into_file 'spec/spec_helper.rb', after: "require 'rspec/autorun'" do
%q<
require 'capybara/rspec'
>
end
insert_into_file 'spec/spec_helper.rb', after: "config.infer_base_class_for_anonymous_controllers = false" do
%q<

  # TODO remember to remove the conflicting line above
  config.use_transactional_fixtures = false

  config.before(:each) do
    if example.metadata[:js]
      DatabaseCleaner.strategy = :truncation
    else
      DatabaseCleaner.strategy = :transaction
    end
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
>
end

run 'spork --bootstrap'
inject_into_file 'spec/spec_helper.rb', after: 'Spork.each_run do' do
%q<
  DatabaseCleaner.clean
  Dir[::Rails.root.join('app','**','*.rb')].each {|f| load f}
  Dir[::Rails.root.join('spec','support','**','*.rb')].each {|f| load f}
  FactoryGirl.reload
  ::Rails.application.reload_routes!
>
end
archive_copy('base/Guardfile', 'Guardfile')

# add default layout and home page
archive_copy('base/layout_helper.rb', 'app/helpers/layout_helper.rb')
archive_copy('base/application.html.haml', 'app/views/layouts/application.html.haml')
remove_file 'app/views/layouts/application.html.erb'

initializer 'generators.rb' do
%q<
Rails.application.config.generators do |g|
  g.test_framework :rspec, fixture: true, views: false
  g.fixture_replacement :factory_girl, dir: 'spec/factories'
  g.template_engine :haml
end
>
end

insert_into_file 'config/application.rb', after: "config.assets.version = '1.0'" do
%q<

    # autoload libs. this was changed in Rails 3
    config.autoload_paths += %W(#{config.root}/lib)
    config.autoload_paths += Dir["#{config.root}/lib/**/"]
>
end

# git :add => "."
# git :commit => '-m "Rails 3.2 app with baseline template"'

say "=====================================", :red
say "Remember to edit spec/spec_helper.rb", :red
say "=====================================", :red
