ARCHIVE ||= File.join(File.dirname(__FILE__), 'archive')

if yes?("Download JQuery Pageless?")
  run 'curl -L http://github.com/jney/jquery.pageless/raw/master/lib/jquery.pageless.js > public/javascripts/jquery.pageless.js'
else
  run "cp #{ARCHIVE}/jquery/jquery.pageless.js public/javascripts/jquery.pageless.js"
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
