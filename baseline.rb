blueprintcss = "/Users/cclow/Code/Ufinity/blueprint-css/blueprint"

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
gem "authlogic"
gem 'mislav-will_paginate', :lib => 'will_paginate',
  :source => "http://gems.github.com"
gem 'justinfrench-formtastic', :lib => 'formtastic',
  :source => "http://gems.github.com"
gem 'haml'
gem "chriseppstein-compass", :lib => "compass",
  :source => "http://gems.github.com"

gem 'cucumber', :lib => false
gem 'webrat', :lib => false
gem "faker", :lib => false
gem "thoughtbot-shoulda", :lib => false,
  :source => "http://gems.github.com"
gem "notahat-machinist", :lib => false,
  :source => "http://gems.github.com"

rake "gems:install", :sudo => true
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
    = stylesheet_link_tag 'application'
    = yield(:head)
  %body.bp
    #container
      - if show_title?
        #header.span-24.last
          %h1.span-24.last=h yield(:title)
      #main.span-15.colborder
        = yield
      #sidebar.span-8.last
        - flash.each do |name, msg|
          = content_tag :div, msg, :class => "\#{name} last"
APPLICATION_HTML

file "public/stylesheets/application.css", <<-APPLICATION_CSS
#container {
  width: 960px;
  margin: 20px auto 0;
}
APPLICATION_CSS

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
require "authlogic/test_case"

class ActionController::TestCase
  setup :activate_authlogic
end
TEST_HELPER
TEST_HELPER_RUN

run <<-ENV_RUN
cat >> features/support/env.rb <<-ENV

require File.expand_path(File.dirname(__FILE__) + "/../../test/machinist")
ENV
ENV_RUN

run "cp config/database.yml config/database_sample.yml"
run "find . -type d -empty | xargs -I xxx touch xxx/.gitignore"

git :add => "."
git :commit => '-m "Rails app with baseline template"'
