gem 'backbone-rails'

initializer 'backbone.rb', <<-BACKBONE
ActiveRecord::Base.include_root_in_json = false
BACKBONE
say '###################################################################'
say 'To complete the Backbone JS installation, run:'
say '  bundle install'
say 'and add to application.js:'
say '  //= require backbone-rails'
say '###################################################################'
