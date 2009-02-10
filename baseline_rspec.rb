git :init
file '.gitignore', <<-GITIGNORE
.DS_Store
log/*.log
tmp/**/*
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

plugin 'rspec', :git => 'git://github.com/dchelimsky/rspec.git'
plugin 'rspec-rails', :git => 'git://github.com/dchelimsky/rspec-rails.git'
generate('rspec')

gem 'cucumber'
gem 'webrat'
generate('cucumber')

gem 'thoughtbot-factory_girl', :lib => 'factory_girl'
gem 'thoughtbot-shoulda', :lib => 'shoulda'
gem 'faker'
gem 'mocha'

gem "sqlite3-ruby", :lib => "sqlite3"
gem 'authlogic'

git :add => '.'
git :commit => '-m "Initial commit"'
