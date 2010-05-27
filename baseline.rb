run 'rm README'
run 'rm doc/README_FOR_APP'
run 'rm public/index.html'
run 'rm public/images/rails.png'
run 'cp config/database.yml config/database-sample.yml'

git :init
run %Q|cat >> '.gitignore', <<-GITIGNORE
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
gem 'rspec-rails', '>=2.0.0.beta.8', :group => :test
gem 'cucumber-rails', :group => :test
gem 'autotest-rails', :group => :test
gem 'rails3-generators', :group => :development

run 'bundle install'
run 'bundle lock'

generate 'rspec:install'
generate 'cucumber:skeleton', "--rspec", "--capybara"

run 'compass init rails . --using blueprint/semantic --quiet --sass-dir app/stylesheets --css-dir public/stylesheets/compiled'

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
    content_for(:head) { javascript_include_tag(*args) }
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
  %body.bp.two-col
    #container
      #header
        %h2=h(@page_title || "Header")
      #sidebar
        %h3 Sidebar
      #content
        %h3 Content
        - flash.each do |name, msg|
          = content_tag :div, msg, :class => name.to_s
        = yield
      #footer
        %h3 Footer
APPLICATION_HTML

generate(:controller, "home", "index")
route "root :to => 'home#index'"

git :add => "."
git :commit => '-m "Rails app with baseline template"'
