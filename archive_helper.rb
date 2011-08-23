require 'open-uri'

def archive_copy(from, to)
  @archive ||= File.join(File.dirname(__FILE__), 'archive')
  if URI.parse(@archive).scheme
    get "#{@archive}/#{from}", to
  else
    copy_file "#{@archive}/#{from}", to
  end
end
