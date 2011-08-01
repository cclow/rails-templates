require 'open-uri'

def archive_copy(from, to)
  @archive ||= File.join(File.dirname(__FILE__), 'archive')
  if URI.parse(@archive).scheme
    run "curl -L #{@archive}/#{from} > #{to}"
  else
    run "cp #{@archive}/#{from} #{to}"
  end
end
