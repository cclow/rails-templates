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

inside("config/environments") do
  run 'cat >> test.rb <<-END_TEST_GEMS
config.gem "cucumber",
  :version => ">=0.1.16"
config.gem "webrat",
  :version => ">=0.4.2"
config.gem "mocha",
  :version => ">=0.9.5"
config.gem "faker",
  :version => ">=0.3.1"
config.gem "thoughtbot-shoulda",
  :lib => "shoulda",
  :source => "http://gems.github.com",
  :version => ">=2.10.0"
config.gem "thoughtbot-factory_girl",
  :lib => "factory_girl",
  :source => "http://gems.github.com",
  :version => ">=1.2.0"
END_TEST_GEMS'
end
# 
gem "dbd-sqlite3",
  :lib => "sqlite3",
  :source => "http://gems.github.com",
  :version => ">=1.2.4"
gem "authlogic",
  :version => ">=1.4.3"
gem 'mislav-will_paginate',
  :lib => 'will_paginate'
  :source => "http://gems.github.com",
  :version => ">=2.3.7"

git :add => '.'
git :commit => '-m "Initial commit"'
