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

gem 'cucumber', :lib => false
gem 'webrat', :lib => false
gem "faker", :lib => false
gem "thoughtbot-shoulda", :lib => false,
  :source => "http://gems.github.com"
gem "notahat-machinist", :lib => false,
  :source => "http://gems.github.com"

run "mkdir -p public/stylesheets/blueprint"
inside("public/stylesheets/blueprint") do
  ["ie.css", "screen.css", "print.css"].each do |f|
    run "cp #{blueprintcss}/#{f} ."
  end
end

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
    = stylesheet_link_tag "blueprint/screen", :media => "screen, projection"
    = stylesheet_link_tag "blueprint/print", :media => "print"
    <!--[if lt IE 8]>
    = stylesheet_link_tag "blueprint/ie", :media => "screen, projection"
    <![endif]-->
    = stylesheet_link_tag 'application'
    = yield(:head)
  %body
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
