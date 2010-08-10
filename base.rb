require 'open-uri'

@archive ||= File.join(File.dirname(__FILE__), 'archive')

def archive_copy(archive, from, to)
  if URI.parse(archive).scheme
    run "curl -L #{archive}/#{from} > #{to}"
  else
    run "cp #{archive}/#{from} #{to}"
  end
end

run 'rm README'
run 'rm doc/README_FOR_APP'
run 'rm public/index.html'
run 'rm public/images/rails.png'

git :init
archive_copy(@archive, 'base/gitignore', '.gitignore')

gem 'haml', '>=3.0.13'
# gem 'sqlite3-ruby', :require => 'sqlite3'
gem 'will_paginate', :branch => 'rails3', :git => 'git://github.com/cclow/will_paginate.git'

gem 'faker', :group => [:test, :development]
gem 'factory_girl_rails', :group => [:test, :development]
gem 'capybara', :group => :test
gem 'rspec-rails', '>=2.0.0.beta.19', :group => :test
gem 'cucumber-rails', :group => :test
gem 'autotest', :group => :test
gem 'autotest-rails', :group => :test
gem 'shoulda', :group => :test
gem 'rails3-generators', :group => :development
gem "awesome_print", :group => :development

run 'bundle install'

generate 'rspec:install'
generate 'cucumber:install', "--rspec", "--capybara"

run 'cp config/database.yml config/database-sample.yml'

archive_copy(@archive, '/cucumber/model_steps.rb', 'features/step_definitions/model_steps.rb')

inject_into_file 'spec/spec_helper.rb', %Q{\# insert shoulda matchers\nrequire 'shoulda'\n},
  :after => %Q{require 'rspec/rails'\n}
inject_into_file 'spec/spec_helper.rb',
  %Q{  include Shoulda::ActiveRecord::Matchers\n  include Shoulda::ActionController::Matchers\n\n},
  :after => %Q{Rspec.configure do |config|\n}

initializer 'factory_girl.rb', <<-FACTORY_GIRL
require File.join(Rails.root, 'factory_girl', 'factories') unless Rails.env == 'production'
FACTORY_GIRL

run 'mkdir factory_girl'
inside 'factory_girl' do
  run 'mkdir factories'
  file 'factories.rb', <<-FACTORIES
require "faker"
require "factory_girl/syntax/sham"

Dir.glob(File.join(File.dirname(__FILE__), "/factories/*.rb")).each { |f| require f }
FACTORIES
end

generate 'haml:install'

run 'mkdir -p app/sass'
run 'mkdir -p public/stylesheets/compiled'
run 'touch app/sass/screen.scss'
run 'touch app/sass/print.scss'
run 'touch app/sass/ie.scss'
run %Q|cat >> config/application.rb <<-SASS
Sass::Plugin.options[:style] = :compact
Sass::Plugin.options[:template_location] = { 'app/sass' => 'public/stylesheets/compiled' }
SASS|

generate 'jquery:install'

application "config.action_view.javascript_expansions[:defaults] = %w(jquery rails)"

if yes?("Apply JQuery Pageless?")
  apply File.join(File.dirname(__FILE__), 'use_pageless.rb')
end

# add default layout and home page
archive_copy(@archive, 'base/layout_helper.rb', 'app/helpers/layout_helper.rb')
archive_copy(@archive, 'base/application.html.haml', 'app/views/layouts/application.html.haml')
run 'rm app/views/layouts/application.html.erb'

initializer 'rails3_generators.rb', <<-RAILS3_GEN
Rails.application.class.configure do
  config.generators do |g|
    g.template_engine :haml
    g.test_framework :rspec, :fixture => true, :views => false
    g.fixture_replacement :factory_girl, :dir => 'factory_girl/factories'
  end
end
RAILS3_GEN

begin
  generate(:controller, 'home', 'index')
  route "root :to => 'home#index'"
end if yes?('Creat default home#index?')

git :add => "."
git :commit => '-m "Rails 3 app with baseline template"'
