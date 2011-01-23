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

gem 'haml', '>=3.0.17'
gem 'will_paginate', ">=3.0.pre2"
gem "simple_form"
gem 'escape_utils'
gem 'hpricot'
gem 'ruby_parser'
gem 'devise'
gem 'cancan'

gem 'faker', :group => [:test, :development]
gem 'factory_girl_rails', :group => [:test, :development]
gem 'rspec-rails', '>=2.0.0.beta.20', :group => [ :test, :development ]
gem 'capybara', :group => :test
gem 'cucumber-rails', :group => :test
gem 'autotest', :group => :test
gem 'autotest-rails', :group => :test
gem 'shoulda', :group => :test
gem 'launchy', :group => :test
gem 'email_spec', :group => :test
gem 'rails3-generators', :group => :development
gem "awesome_print", :group => :development
gem "haml-rails", :group => :development
gem 'jquery-rails', :group => :development

run 'bundle install'

generate 'cancan:ability'
generate 'simple_form:install'
generate 'rspec:install'
generate 'cucumber:install', "--rspec", "--capybara"

run 'cp config/database.yml config/database-sample.yml'

archive_copy(@archive, '/base/escape_utils.rb', 'config/initializers/escape_utils.rb')

run 'mkdir -p spec/support'
archive_copy(@archive, '/base/shoulda.rb', 'spec/support/shoulda.rb')

initializer 'factory_girl.rb', <<-FACTORY_GIRL
require File.join(Rails.root, 'factory_girl', 'factories') unless Rails.env == 'production'
FACTORY_GIRL

run 'mkdir -p factory_girl/factories'
archive_copy(@archive, 'base/factories.rb', 'factory_girl/factories.rb')

generate 'haml:install'

run 'mkdir -p app/sass'
run 'mkdir -p public/stylesheets/compiled'
run 'touch app/sass/screen.scss'
run 'touch app/sass/print.scss'
run 'touch app/sass/ie.scss'

initializer 'sass.rb', <<-SASS
Sass::Plugin.options[:style] = :compact
Sass::Plugin.options[:template_location] = { 'app/sass' => 'public/stylesheets/compiled' }
SASS

generate 'jquery:install'

gsub_file "config/application.rb", /^\s+# JavaScript.*\n/, ""
gsub_file "config/application.rb", /^\s+config\.action_view\.javascript.*\n/, ""
application "config.action_view.javascript_expansions[:defaults] = %w(jquery.min rails)"

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

apply File.join(File.dirname(__FILE__), 'use_auto_focus.rb')

if yes?("Apply JQuery Pageless?")
  apply File.join(File.dirname(__FILE__), 'use_pageless.rb')
end

if yes?("Apply JQuery Anytime Date Time Picker?")
  apply File.join(File.dirname(__FILE__), 'use_anytime.rb')
end

git :add => "."
git :commit => '-m "Rails 3 app with baseline template"'
