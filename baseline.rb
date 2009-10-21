git :init
file '.gitignore', <<-GITIGNORE
.DS_Store
log/*.log
tmp/**/*
tmp/*
TAGS
*~
.#*
db/schema.rb
db/*_structure.sql
db/*.sqlite3
db/*.sqlite
db/*.db
*.sqlite
*.sqlite3
*.db
src/*
.hgignore
.hg/*
.svn/*
config/database.yml
doc/api
doc/app
coverage/*
*.swp
public/stylesheets/compiled/*
GITIGNORE

run 'rm README'
run 'rm doc/README_FOR_APP'
run 'rm public/index.html'
run 'rm public/robots.txt'
run 'rm public/images/rails.png'

#
gem "dbd-sqlite3", :lib => "sqlite3"
gem 'mislav-will_paginate', :lib => 'will_paginate',
  :source => "http://gems.github.com"
gem 'justinfrench-formtastic', :lib => 'formtastic',
  :source => "http://gems.github.com"
gem "chriseppstein-compass", :lib => "compass",
  :source => "http://gems.github.com"
gem 'haml'

gem 'cucumber', :lib => false
gem 'webrat', :lib => false
gem "faker", :lib => false
gem "thoughtbot-shoulda", :lib => false,
  :source => "http://gems.github.com"
gem "notahat-machinist", :lib => false,
  :source => "http://gems.github.com"

require "haml" rescue rake "gems:install GEM=haml", :sudo => true
require "compass" rescue rake "gems:install GEM=chriseppstein-compass", :sudo => true
rake "gems:unpack GEM=chriseppstein-compass"

file 'vendor/plugins/compass/init.rb', <<-CODE
# This is here to make sure that the right version of sass gets loaded (haml 2.2) by the compass requires.
require 'compass'
CODE

run "haml --rails ."
run "compass --rails -f blueprint . --css-dir=public/stylesheets/compiled --sass-dir=app/stylesheets"

# add default layout and home page
file "app/helpers/layout_helper.rb", <<-LAYOUT_HELPER
module LayoutHelper
  def title(page_title, show_title = true)
    @content_for_title = page_title.to_s
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

file "app/views/layouts/application.html.haml", <<-APPLICATION_HTML
!!!
%html
  %head
    %title= h(yield(:title) || "Untitled")
    = stylesheet_link_tag 'compiled/screen.css', :media => 'screen, projection'
    = stylesheet_link_tag 'compiled/print.css', :media => 'print'
    /[if lt IE 8]
      = stylesheet_link_tag 'compiled/ie.css', :media => 'screen, projection'
    = stylesheet_link_tag 'compiled/application.css', :media => 'screen, projection'
    = yield(:head)
  %body.bp.three-col
    #container
      - if show_title?
        #header
          %h2=h yield(:title)
      #content
        = yield
      #sidebar
        %h3 Sidebar
        - flash.each do |name, msg|
          = content_tag :div, msg, :class => "\#{name} last"
APPLICATION_HTML

file "app/stylesheets/application.sass", <<-APPLICATION_SASS
body.three-col
  #container
    width: 960px
    margin: 20px auto 0
APPLICATION_SASS

generate(:controller, "home", "index")
route 'map.root :controller => "home"'
run "rm app/views/home/index.html.erb"
file "app/views/home/index.html.haml", <<-INDEX_HTML
- title "Home Page"
<p>Et vel ut et aspernatur commodi sequi labore.
Voluptatem ullam at error possimus ut rerum ut.
Sunt illo fuga sed nemo.
Dolorum rerum quia commodi aut iure dolorem cum.
Accusantium eos perspiciatis voluptatibus ipsum.</p>
INDEX_HTML

# setup testing
generate(:cucumber, "--testunit")

webrat_steps="features/step_definitions/webrat_steps.rb"
run %Q|sed -e "s/(regexp)/(regexp, Regexp::IGNORECASE)/" #{webrat_steps} > #{webrat_steps}.new && mv #{webrat_steps}.new #{webrat_steps}|

file "cucumber.yml", <<-CUCUMBER_YML
default: -r features -v
autotest: -r features
autotest-all: features -r features -f progress
CUCUMBER_YML

run "mkdir -p test/machinist"

file "test/machinist.rb", <<-MACHINIST
require "machinist/active_record"
require "sham"
require "faker"

Dir.glob(File.join(File.dirname(__FILE__), "/machinist/*.rb")).each { |f| require f }
MACHINIST

run <<-TEST_HELPER_RUN
cat >> test/test_helper.rb <<-TEST_HELPER

require "shoulda"
require File.expand_path(File.dirname(__FILE__) + "/machinist")
TEST_HELPER
TEST_HELPER_RUN

run <<-ENV_RUN
cat >> features/support/env.rb <<-ENV

require File.expand_path(File.dirname(__FILE__) + "/../../test/machinist")
ENV
ENV_RUN

file "features/step_definitions/model_steps.rb", <<-MODEL_STEPS
Given /^there (is|are) (\\d+) "([^\\"]*)" records?$/ do |_, count, model|
  @records ||= {}
  @records[model] ||= []
  klass = model.camelize.constantize
  count.to_i.times do |i|
    @records[model][i] = klass.make
  end
end

When /^I fill in "([^\\"]*)" with "([^\\"]*)" value from "([^\\"]*)" record$/ do |field, attr, model|
  When %Q(I fill in "\#{field}" with "\#{@records[model][0].send(attr)}")
end

When /^I fill in "([^\\"]*)" with previous "([^\\"]*)"$/ do |field, key|
  When %Q(I fill in "\#{field}" with "\#{@values[key]}")
end

When /^I fill in "([^\\"]*)" with sham "([^\\"]*)"$/ do |field, key|
  @values ||= {}
  @values[key] = Sham.send(key)
  When %Q(I fill in "\#{field}" with "\#{@values[key]}")
end

Then /^I should see "([^\\"]*)" value of "([^\\"]*)" record$/ do |attr, model|
  Then %Q(I should see "\#{@records[model][0].send(attr)}")
end

Then /^I should see "([^\\"]*)" values of "([^\\"]*)" records$/ do |attr, model|
  @records[model].each do |record|
    Then %Q(I should see "\#{record.send(attr)}")
  end
end
MODEL_STEPS

run "cp config/database.yml config/database_sample.yml"
run "find . -type d -empty | xargs -I xxx touch xxx/.gitignore"

git :add => "."
git :commit => '-m "Rails app with baseline template"'
