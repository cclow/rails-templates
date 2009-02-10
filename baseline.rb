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

if yes?("Use jQuery?")
  load_template( 'http://github.com/cclow/rails-templates/raw/master/use_jquery.rb')
end

run "cp config/database.yml config/example_database.yml"
run "find . -type d -empty | xargs -I xxx touch xxx/.gitignore"

# gem 'cucumber'
# gem 'webrat'
gem 'thoughtbot-factory_girl', :lib => 'factory_girl'
gem 'thoughtbot-shoulda', :lib => 'shoulda'
gem 'faker'
gem 'mocha'

gem "sqlite3-ruby", :lib => "sqlite3"
gem 'authlogic'
gem 'mislav-will_paginate', :lib => 'will_paginate'

git :add => '.'
git :commit => '-m "Initial commit"'
