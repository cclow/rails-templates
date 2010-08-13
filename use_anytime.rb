require 'open-uri'

@pageless_archive ||= File.join(File.dirname(__FILE__), 'archive', 'jquery', 'anytime')

if URI.parse(@pageless_archive).scheme
  run %Q{curl -L #{@pageless_archive}/anytime.js > public/javascripts/anytime.js}
  run %Q{curl -L #{@pageless_archive}/anytime.css > public/stylesheets/anytime.css}
  run %Q{curl -L #{@pageless_archive}/anytime_helper.rb > app/helpers/anytime_helper.rb}
else
  run %Q{cp #{@pageless_archive}/anytime.js public/javascripts/anytime.js}
  run %Q{cp #{@pageless_archive}/anytime.css public/stylesheets/anytime.css}
  run %Q{cp #{@pageless_archive}/anytime_helper.rb app/helpers/anytime_helper.rb}
end
