run 'rm README'
run 'rm doc/README_FOR_APP'
run 'rm public/index.html'
run 'rm public/images/rails.png'

git :init
run %Q|cat >> '.gitignore' <<-GITIGNORE
.bundle
db/*.sqlite3
log/*.log
tmp/**/*
.DS_Store
TAGS
*~
.#*
db/schema.rb
db/*.sqlite3
config/database.yml
doc/api
doc/app
coverage/*
*.swp
public/stylesheets/compiled/*
GITIGNORE|

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

inject_into_file 'spec/spec_helper.rb', %Q{\# insert shoulda matchers\nrequire 'shoulda'\n},
  :after => %Q{require 'rspec/rails'\n}
inject_into_file 'spec/spec_helper.rb',
  %Q{  include Shoulda::ActiveRecord::Matchers\n  include Shoulda::ActionController::Matchers\n\n},
  :after => %Q{Rspec.configure do |config|\n}

if yes?('Download JQuery?')
  run 'curl -L http://code.jquery.com/jquery-1.4.2.min.js > public/javascripts/jquery.js'
  run 'curl -L http://github.com/rails/jquery-ujs/raw/master/src/rails.js > public/javascripts/rails.js'
else
  run 'cp ../rails-templates/archive/jquery/rails.js public/javascripts/rails.js'
  run 'cp ../rails-templates/archive/jquery/jquery-1.4.2.min.js public/javascripts/jquery.js'
end

application %Q{config.action_view.javascript_expansions[:defaults] = %w(jquery rails)}

initializer 'factory_girl.rb', <<-FACTORY_GIRL
require File.join(Rails.root, 'factory_girl', 'factories') unless Rails.env == 'production'
FACTORY_GIRL

run 'mkdir factory_girl'
inside 'factory_girl' do
  run 'mkdir factories'
  file 'factories.rb', <<-FACTORIES
require "faker"

Dir.glob(File.join(File.dirname(__FILE__), "/factories/*.rb")).each { |f| require f }
FACTORIES
end


# add default layout and home page
file "app/helpers/layout_helper.rb", <<-LAYOUT_HELPER
module LayoutHelper
  def title(page_title, show_title = true)
    @page_title = page_title.to_s
    @show_title = show_title
  end

  def show_title?
    @show_title
  end

  def stylesheet(*args)
    content_for(:head) { stylesheet_link_tag(*args) }
  end

  def javascript(*args)
    content_for(:js) { javascript_include_tag(*args) }
  end
end
LAYOUT_HELPER

run 'rm app/views/layouts/application.html.erb'

file "app/views/layouts/application.html.haml", <<-APPLICATION_HTML
!!!
%html
  %head
    %title= h(@page_title || "Untitled")
    = stylesheet_link_tag 'compiled/screen.css', :media => 'screen, projection'
    = stylesheet_link_tag 'compiled/print.css', :media => 'print'
    /[if lt IE 8]
      = stylesheet_link_tag 'compiled/ie.css', :media => 'screen, projection'
    = yield(:head)
    = csrf_meta_tag
  %body.bp.two-col
    #container
      #header
        %h2= h(@page_title || "Header")
      #sidebar
        %h3 Sidebar
      #content
        %h3 Content
        - flash.each do |name, msg|
          = content_tag :div, msg, :class => name.to_s
        = yield
      #footer
        %h3 Footer
    = javascript_include_tag :defaults, :cache => true
    = yield(:js)
APPLICATION_HTML

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
