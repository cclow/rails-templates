# run with
# rails new project -T --skip-bundle -m rails-templates/base.rb
#
require File.join(File.dirname(__FILE__), 'archive_helper')

git :init

# Need to do this before call the template since
# doing a run "rvm ..." does not change the rvm gemset
create_file '.rvmrc', "rvm use #{`rvm current`.strip}"

run 'cp config/database.yml config/database-sample.yml'
archive_copy('base/gitignore', '.gitignore')

gsub_file 'Gemfile', /(gem 'sass-rails')/, '# \1'
append_file 'Gemfile', <<-GEMFILE
gem 'simple_form'
group :assets do
  gem 'haml-rails'
  gem 'modernizr-rails'
  gem 'less-rails'
  gem 'twitter-bootstrap-rails'
end
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

generate 'rspec:install'
inside 'spec' do
  empty_directory 'routing'
  empty_directory 'support'
  empty_directory 'requests'
  empty_directory 'acceptance'
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

run 'spork --bootstrap'
inject_into_file 'spec/spec_helper.rb', after: 'Spork.each_run do' do
%q<
  Dir[::Rails.root.join('app','**','*.rb')].each {|f| load f}
  Dir[::Rails.root.join('spec','support','**','*.rb')].each {|f| load f}
  FactoryGirl.reload
  ::Rails.application.reload_routes!
>
end
archive_copy('base/Guardfile', 'Guardfile')

generate 'bootstrap:install'
generate 'bootstrap:layout application fixed'
archive_copy('base/layout_helper.rb', 'app/helpers/layout_helper.rb')
remove_file 'app/views/layouts/application.html.erb'
generate 'simple_form:install --bootstrap'

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
