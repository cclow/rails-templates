module PagelessHelper
  def pageless_js(collection, div, url=nil)
    opts = {
      :totalPages => collection.total_pages,
      :url        => url,
      :loaderMsg  => 'Loading more results'
    }
    js_include('jquery.pageless.js')
    ready_js("$('##{div}').pageless(#{opts.to_json});")
  end
end
