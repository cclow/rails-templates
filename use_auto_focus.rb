@auto_focus_archive ||= File.join(File.dirname(__FILE__), 'archive', 'jquery', 'auto-focus')

if URI.parse(@auto_focus_archive).scheme
  run %Q{curl -L #{@auto_focus_archive}/auto_focus_helper.rb > app/helpers/auto_focus_helper.rb}
else
  run %Q{cp #{@auto_focus_archive}/auto_focus_helper.rb app/helpers/auto_focus_helper.rb}
end
