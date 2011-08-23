require File.join(File.dirname(__FILE__), 'archive_helper')

run 'mkdir -p vendor/assets/javascripts'
archive_copy('knockout/knockout.js', 'vendor/assets/javascripts/knockout.js')
archive_copy('jquery/jquery.tmpl/jquery.tmpl.js', 'vendor/assets/javascripts/jquery.tmpl.js')
