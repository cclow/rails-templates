run 'rm README'
run 'rm doc/README_FOR_APP'
run 'rm public/index.html'
run 'rm public/images/rails.png'
run 'cp config/database.yml config/database-sample.yml'

git :init
run %Q|cat >> '.gitignore' <<-GITIGNORE
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

gem 'haml', ">=3.0.0.rc.5"
gem 'compass', '>=0.10.1'

gem 'faker', :group => :test
gem 'factory_girl', :git => 'git://github.com/cclow/factory_girl.git', :branch => 'rails3', :group => :test
gem 'capybara', :group => :test
gem 'rspec-rails', '>=2.0.0.beta.9', :group => :test
gem 'cucumber-rails', :group => :test
gem 'autotest', :group => :test
gem 'autotest-rails', :group => :test
gem 'rails3-generators', :group => :development

run 'bundle install'
run 'bundle lock'

generate 'rspec:install'
generate 'cucumber:skeleton', "--rspec", "--capybara"

run 'compass init rails . --using blueprint/semantic --quiet --sass-dir app/stylesheets --css-dir public/stylesheets/compiled'

run 'mkdir public/javascripts/jquery'
run 'curl -L http://code.jquery.com/jquery-1.4.2.min.js > public/javascripts/jquery/jquery-1.4.2.min.js'
run 'curl -L http://github.com/rails/jquery-ujs/raw/master/src/rails.js > public/javascripts/rails.js'

initializer 'jquery.rb', <<-JQUERY
module ActionView::Helpers::AssetTagHelper
  remove_const :JAVASCRIPT_DEFAULT_SOURCES
  JAVASCRIPT_DEFAULT_SOURCES = %w(jquery/jquery-1.4.2.min.js rails.js)

  reset_javascript_include_default
end
JQUERY

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
    g.fixture_replacement :factory_girl, :dir => 'spec/factories'
  end
end
RAILS3_GEN

begin
  generate(:controller, 'home', 'index')
  route "root :to => 'home#index'"
end if yes?('Creat default home#index?')

git :add => "."
git :commit => '-m "Rails 3 app with baseline template"'
