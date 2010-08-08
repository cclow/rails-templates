require File.join(File.dirname(__FILE__), 'lib', 'copy_archive')

copy_from_archive "jquery/jquery.pageless.js", "public/javascripts/jquery.pageless.js"

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
