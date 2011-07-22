# run with
# rails new project -T --skip-bundle -m rails-templates/base.rb
#
require 'open-uri'

@archive ||= File.join(File.dirname(__FILE__), 'archive')

def archive_copy(archive, from, to)
  if URI.parse(archive).scheme
    run "curl -L #{archive}/#{from} > #{to}"
  else
    run "cp #{archive}/#{from} #{to}"
  end
end

git :init

run 'echo "rvm use `rvm current`" | sed "s/@.*//" > .rvmrc'
run 'rvm rvmrc trust'

run 'rm doc/README_FOR_APP'
run 'rm public/index.html'
run 'rm app/assets/images/rails.png'

gem "simple_form"
gem "haml-rails"

gem 'faker', :group => [:test, :development]
gem 'factory_girl_rails', :group => [:test, :development]
gem 'rspec-rails', :group => [ :test, :development ]
gem 'capybara', :group => :test
gem 'autotest', :group => :test
gem 'autotest-rails', :group => :test
gem 'shoulda-matchers', :group => :test
gem 'launchy', :group => :test
gem 'email_spec', :group => :test
gem 'rails3-generators', :group => :development
gem "awesome_print", :group => :development

run 'bundle install --path vendor && bundle package && echo "vendor/ruby" >> .gitignore'

generate 'simple_form:install'
generate 'rspec:install'

run 'cp config/database.yml config/database-sample.yml'
run 'echo "config/database.yml" >> .gitignore'

# add default layout and home page
archive_copy(@archive, 'base/layout_helper.rb', 'app/helpers/layout_helper.rb')
run 'rm app/views/layouts/application.html.erb'
archive_copy(@archive, 'base/application.html.haml', 'app/views/layouts/application.html.haml')
archive_copy(@archive, 'base/images/favicon.ico', 'app/assets/images/favicon.ico')
archive_copy(@archive, 'base/images/apple-touch-icon.png', 'app/assets/images/apple-touch-icon.png')
archive_copy(@archive, 'base/images/apple-touch-icon-72x72.png', 'app/assets/images/apple-touch-icon-72x72.png')
archive_copy(@archive, 'base/images/apple-touch-icon-114x114.png', 'app/assets/images/apple-touch-icon-114x114.png')
archive_copy(@archive, 'base/stylesheets/base.css', 'app/assets/stylesheets/base.css')
archive_copy(@archive, 'base/stylesheets/skeleton.css', 'app/assets/stylesheets/skeleton.css')
archive_copy(@archive, 'base/stylesheets/layout.css', 'app/assets/stylesheets/layout.css')
archive_copy(@archive, 'base/javascripts/tabs.js', 'app/assets/javascripts/tabs.js')

initializer 'rails3_generators.rb', <<-RAILS3_GEN
Rails.application.config.generators do |g|
  g.test_framework :rspec, :fixture => true, :views => false
  g.fixture_replacement :factory_girl, :dir => 'spec/factories'
  g.form_builder :simple_form
  g.template_engine :haml
end
RAILS3_GEN

git :add => "."
git :commit => '-m "Rails 3.1 app with baseline template"'
