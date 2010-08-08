require 'open-uri'

@archive ||= File.join(File.dirname(__FILE__), 'archive')

if URI.parse(@archive).scheme
  run %Q{curl -L #{@archive}/jquery/jquery.pageless.js > public/javascripts/jquery.pageless.js}
else
  run %Q{cp #{@archive}/jquery/jquery.pageless.js public/javascripts/jquery.pageless.js}
end

file "app/helpers/pageless_helper.rb", <<-PAGELESS_HELPER
module PagelessHelper
  def pageless_js(div, total_pages, url=nil)
    opts = {
      :totalPages => total_pages,
      :url        => url,
      :loaderMsg  => 'Loading more results'
    }
  
    content_for(:js) do
      javascript_tag %Q{$('\#{div}').pageless(\#{opts.to_json});}
    end
  end
end
PAGELESS_HELPER
