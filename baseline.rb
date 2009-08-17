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
GITIGNORE

run 'rm README'
run 'rm doc/README_FOR_APP'
run 'rm public/index.html'
run 'rm public/favicon.ico'
run 'rm public/robots.txt'

# 
gem "dbd-sqlite3",
  :lib => "sqlite3",
  :source => "http://gems.github.com"
gem "authlogic"
gem 'mislav-will_paginate',
  :lib => 'will_paginate',
  :source => "http://gems.github.com"

gem 'cucumber',
  :lib => false
gem 'webrat',
  :lib => false
gem "faker",
  :lib => false
gem "thoughtbot-shoulda",
  :lib => false,
  :source => "http://gems.github.com"
gem "notahat-machinist",
  :lib => false,
  :source => "http://gems.github.com"

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

file "app/views/layouts/application.html.erb", <<-APPLICATION_HTML
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
  <head>
    <title><%%= h(yield(:title) || "Untitled") %></title>
    <%= stylesheet_link_tag 'application' %>
    <%= yield(:head) %>
  </head>
  <body>
    <div id="container">
      <%- flash.each do |name, msg| -%>
        <%= content_tag :div, msg, :id => "flash_\#{name}" %>
      <%- end -%>

      <%- if show_title? -%>
        <h1><%=h yield(:title) %></h1>
      <%- end -%>

      <%= yield %>
    </div>
  </body>
</html>
APPLICATION_HTML

file "public/stylesheets/application.css", <<-APPLICATION_CSS
body {
  background-color: #4B7399;
  font-family: Verdana, Helvetica, Arial;
  font-size: 14px;
}

a img {
  border: none;
}

a {
  color: #0000FF;
}

.clear {
  clear: both;
  height: 0;
  overflow: hidden;
}

#container {
  width: 75%;
  margin: 0 auto;
  background-color: #FFF;
  padding: 20px 40px;
  border: solid 1px black;
  margin-top: 20px;
}

#flash_notice, #flash_error {
  padding: 5px 8px;
  margin: 10px 0;
}

#flash_notice {
  background-color: #CFC;
  border: solid 1px #6C6;
}

#flash_error {
  background-color: #FCC;
  border: solid 1px #C66;
}

.fieldWithErrors {
  display: inline;
}

#errorExplanation {
  width: 400px;
  border: 2px solid #CF0000;
  padding: 0px;
  padding-bottom: 12px;
  margin-bottom: 20px;
  background-color: #f0f0f0;
}

#errorExplanation h2 {
  text-align: left;
  font-weight: bold;
  padding: 5px 5px 5px 15px;
  font-size: 12px;
  margin: 0;
  background-color: #c00;
  color: #fff;
}

#errorExplanation p {
  color: #333;
  margin-bottom: 0;
  padding: 8px;
}

#errorExplanation ul {
  margin: 2px 24px;
}

#errorExplanation ul li {
  font-size: 12px;
  list-style: disc;
}
APPLICATION_CSS

generate(:controller, "home", "index")
route 'map.root :controller => "home"'

# setup testing
generate(:cucumber, "--testunit")
file "cucumber.yml", <<-CUCUMBER_YML
default: -r features/support -r features/step_definitions
CUCUMBER_YML

run "mkdir -p test/blueprints"

file "test/blueprints.rb", <<-BLUEPRINTS
require "machinist/active_record"
require "sham"
require "faker"

Dir.glob(File.join(File.dirname(__FILE__), "/blueprints/*.rb")).each { |f| require f }
BLUEPRINTS

run <<-TEST_HELPER_RUN
cat >> test/test_helper.rb <<-TEST_HELPER

require "shoulda"
require File.expand_path(File.dirname(__FILE__) + "/blueprints")
require "authlogic/test_case"

class ActionController::TestCase
  setup :activate_authlogic
end
TEST_HELPER
TEST_HELPER_RUN

run <<-ENV_RUN
cat >> features/support/env.rb <<-ENV

require File.expand_path(File.dirname(__FILE__) + '/../../test/blueprints')
ENV
ENV_RUN

run "cp config/database.yml config/database_sample.yml"
run "find . -type d -empty | xargs -I xxx touch xxx/.gitignore"

git :add => '.'
git :commit => '-m "Rails app with baseline template"'
