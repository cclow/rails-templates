gem 'jasmine'
gem 'jasminerice'
gem 'guard-jasmine'

run 'guard init jasmine'
empty_directory 'spec/javascripts'

create_file 'spec/javascripts/spec.js.coffee', <<-SPEC_JS
#= require application
#= require_tree ./
SPEC_JS

create_file 'spec/javascripts/spec.css', <<-SPEC_CSS
/*
 *= require application
 */
SPEC_CSS
