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

run "cp config/database.yml config/example_database.yml"
run "find . -type d -empty | xargs -I xxx touch xxx/.gitignore"

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
generate(:nifty_layout)
generate(:controller, "home", "index")
route 'map.root :controller => "home"'

# setup testing
generate(:cucumber, "--testunit")

file "test/blueprints.rb", <<-BLUEPRINTS
require "machinist/active_record"
require "sham"
require "faker"

BLUEPRINTS

run <<-TEST_HELPER_RUN
cat >> test/test_helper.rb <<-TEST_HELPER

require "shoulda"
require File.expand_path(File.dirname(__FILE__) + "/blueprints")
TEST_HELPER
TEST_HELPER_RUN

run <<-ENV_RUN
cat >> features/support/env.rb <<-ENV

require File.expand_path(File.dirname(__FILE__) + '/../../test/blueprints')
ENV
ENV_RUN

git :add => '.'
git :commit => '-m "Rails app with baseline template"'
