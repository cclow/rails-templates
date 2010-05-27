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
GITIGNORE|

gem 'haml', ">=3.0.0.rc.5"
gem 'compass', '>=0.10.1'

gem 'faker', :group => :test
gem 'factory_girl', :git => 'git://github.com/cclow/factory_girl.git', :branch => 'rails3', :group => :test
gem 'capybara', :group => :test
gem 'rspec-rails', '>=2.0.0.beta.8', :group => :test
gem 'cucumber-rails', :group => :test
gem 'autotest-rails', :group => :test
run 'bundle install'

generate 'rspec:install'
generate 'cucumber:skeleton', "--rspec", "--capybara"

run 'compass init rails . --using blueprint/semantic --quiet --sass-dir public/stylesheets/sass --css-dir public/stylesheets/'

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
    = stylesheet_link_tag 'screen.css', :media => 'screen, projection'
    = stylesheet_link_tag 'print.css', :media => 'print'
    /[if lt IE 8]
      = stylesheet_link_tag 'ie.css', :media => 'screen, projection'
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
# 
# file "app/stylesheets/application.sass", <<-APPLICATION_SASS
# body.three-col
#   #container
#     width: 960px
#     margin: 20px auto 0
# APPLICATION_SASS
# 
# generate(:controller, "home", "index")
# route 'map.root :controller => "home"'
# run "rm app/views/home/index.html.erb"
# file "app/views/home/index.html.haml", <<-INDEX_HTML
# - title "Home Page"
# <p>Et vel ut et aspernatur commodi sequi labore.
# Voluptatem ullam at error possimus ut rerum ut.
# Sunt illo fuga sed nemo.
# Dolorum rerum quia commodi aut iure dolorem cum.
# Accusantium eos perspiciatis voluptatibus ipsum.</p>
# INDEX_HTML
# 
# file "features/step_definitions/model_steps.rb", <<-MODEL_STEPS
# Given /^there (is|are) (\\d+) "([^\\"]*)" records?$/ do |_, count, model|
#   @records ||= {}
#   @records[model] ||= []
#   klass = model.camelize.constantize
#   count.to_i.times do |i|
#     @records[model][i] = klass.make
#   end
# end
# 
# When /^I fill in "([^\\"]*)" with "([^\\"]*)" value from "([^\\"]*)" record$/ do |field, attr, model|
#   When %Q(I fill in "\#{field}" with "\#{@records[model][0].send(attr)}")
# end
# 
# When /^I fill in "([^\\"]*)" with previous "([^\\"]*)"$/ do |field, key|
#   When %Q(I fill in "\#{field}" with "\#{@values[key]}")
# end
# 
# When /^I fill in "([^\\"]*)" with sham "([^\\"]*)"$/ do |field, key|
#   @values ||= {}
#   @values[key] = Sham.send(key)
#   When %Q(I fill in "\#{field}" with "\#{@values[key]}")
# end
# 
# Then /^I should see "([^\\"]*)" value of "([^\\"]*)" record$/ do |attr, model|
#   Then %Q(I should see "\#{@records[model][0].send(attr)}")
# end
# 
# Then /^I should see "([^\\"]*)" values of "([^\\"]*)" records$/ do |attr, model|
#   @records[model].each do |record|
#     Then %Q(I should see "\#{record.send(attr)}")
#   end
# end
# MODEL_STEPS
# 
# run "find . -type d -empty | xargs -I xxx touch xxx/.gitignore"

git :add => "."
git :commit => '-m "Rails app with baseline template"'
