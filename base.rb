# run with
# rails new project -T --skip-bundle -m rails-templates/base.rb
#
require File.join(File.dirname(__FILE__), 'archive_helper')

git :init

# Need to do this before call the template since
# doing a run "rvm ..." does not change the rvm gemset
#
# run "rvm use --create #{ruby}@#{app_name}"
#
# ruby_gemset = `rvm current`.strip
# run "rvm --rvmrc #{ruby_gemset}"

# remove_file 'doc/README_FOR_APP'
# remove_file 'public/index.html'
# remove_file 'app/assets/images/rails.png'

run 'cp config/database.yml config/database-sample.yml'
archive_copy('base/gitignore', '.gitignore')

append_file 'Gemfile', <<-GEMFILE
group :assets do
  # HTML5 modernizr Javascript library for feature detection
  # Uncomment here and in appication.html.haml
  # gem 'modernizr-rails'

  # SASS Mixins
  gem 'bourbon'

  # Twitter Bootstrap framework in SASS
  # gem 'bootstrap-sass'
end

# use simple_form form builder
gem 'simple_form'

# use HAML templates instead of ERB
gem 'haml-rails'

group :development do
  # includes pry, awesome_print, hirb, pry doc, pry git, pry remote,
  # pry debugger, pry stack explorer, coolline and coderay
  gem 'jazz_hands'

  # miniprofiler
  # http://samsaffron.com/archive/2012/07/12/miniprofiler-ruby-edition
  gem 'rack-mini-profiler'

  # Bullet for database query optimisation
  gem 'bullet'
end

group :test do
  # RSpec, matchers and capaybara
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'capybara', require: false

  # Launchy, mainly for capybara's save_and_open_page
  # https://github.com/copiousfreetime/launchy/
  gem 'launchy'

  # cookie help for capybara integration tests
  # https://github.com/nruth/show_me_the_cookies
  gem 'show_me_the_cookies'

  # Cleans database for tests
  # https://github.com/bmabey/database_cleaner/
  gem 'database_cleaner'

  # for Mac OS X User Notifications used by guard
  gem 'terminal-notifier'

  # Spork for parallel tests execution
  gem 'spork'

  # Guard packages
  gem 'guard-bundler'
  gem 'guard-migrate'
  gem 'guard-spork'
  gem 'guard-rspec'

  # File system event observer for Mac OS X, used by guard
  gem 'rb-fsevent', require: false if RUBY_PLATFORM =~ /darwin/i

  # Code coverage in Ruby 1.9
  # https://github.com/colszowka/simplecov
  gem 'simplecov', require: false
end

group :test, :development do
  # Fake test data
  gem 'faker'

  # Test fixture replacement
  gem 'factory_girl_rails'

  # Factory girl replacement
  # https://github.com/stephencelis/miniskirt
  # gem 'miniskirt'
  # Mutes asset pipeline messages
  # https://github.com/evrone/quiet_assets/
  gem 'quiet_assets'
end
GEMFILE

run 'bundle install'

########################################
# Install simple_form
# If Twitter Bootstrap used, then rerun this using
#   rails generate simple_form:install --bootstrap
generate 'simple_form:install'

# Install and set up rspec
generate 'rspec:install'
inside 'spec' do
  empty_directory 'routing'
  empty_directory 'support'
  empty_directory 'requests'
end

inject_into_file 'spec/spec_helper.rb', after: "require 'rspec/autorun'" do
%q<
require 'capybara/rspec'

unless ENV['DRB']
  require 'simplecov'
  SimpleCov.start 'rails'
end
>
end

insert_into_file 'spec/spec_helper.rb', after: "config.infer_base_class_for_anonymous_controllers = false" do
%q<

  # TODO remember to remove the conflicting line above
  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.clean_with :truncation
  end

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

########################################
# Setup spork
run 'spork --bootstrap'
inject_into_file 'spec/spec_helper.rb', after: 'Spork.each_run do' do
%q<
  if ENV['DRB']
    require 'simplecov'
    SimpleCov.start 'rails'
  end
  Dir[::Rails.root.join('app','**','*.rb')].each {|f| load f}
  Dir[::Rails.root.join('spec','support','**','*.rb')].each {|f| load f}
  FactoryGirl.reload
  ::Rails.application.reload_routes!
>
end

########################################
# Set up Guardfile for guard
# support for guard-bundler, -migrate, -spork, -rspec
archive_copy('base/Guardfile', 'Guardfile')

########################################
# add default layout and home page
archive_copy('base/layout_helper.rb', 'app/helpers/layout_helper.rb')
archive_copy('base/application.html.haml', 'app/views/layouts/application.html.haml')
remove_file 'app/views/layouts/application.html.erb'

########################################
initializer 'generators.rb' do
%q<
Rails.application.config.generators do |g|
  g.test_framework :rspec, fixture: true, views: false
  g.fixture_replacement :factory_girl, dir: 'spec/factories'
  g.template_engine :haml
end
>
end

########################################
# Bullet initializer
initializer 'bullet.rb' do
%q<
if defined? Bullet
  Bullet.enable = true
  # Bullet.alert = true
  Bullet.bullet_logger = true
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
