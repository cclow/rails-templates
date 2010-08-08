require 'open-uri'

module CopyArchive
  def copy_from_archive(from, to)
    @archive ||= File.join(File.dirname(__FILE__), '..', 'archive')
    if URI.parse(@archive).scheme
      run %Q{curl -L #{@archive}/#{from} > #{to}}
    else
      run %Q{cp #{@archive}/#{from} #{to}}
    end
  end
end

include CopyArchive
