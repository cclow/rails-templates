require 'open-uri'

@pageless_archive ||= File.join(File.dirname(__FILE__), 'archive', 'jquery', 'pageless')

if URI.parse(@pageless_archive).scheme
  run %Q{curl -L #{@pageless_archive}/jquery.pageless.js > public/javascripts/jquery.pageless.js}
  run %Q{curl -L #{@pageless_archive}/pageless_helper.rb > app/helpers/pageless_helper.rb}
  run %Q{curl -L #{@pageless_archive}/load.gif > public/images/load.gif}
else
  run %Q{cp #{@pageless_archive}/jquery.pageless.js public/javascripts/jquery.pageless.js}
  run %Q{cp #{@pageless_archive}/pageless_helper.rb app/helpers/pageless_helper.rb}
  run %Q{cp #{@pageless_archive}/load.gif public/images/load.gif}
end
