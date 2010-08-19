module LayoutHelper
  def title(page_title, show_title = true)
    @page_title = page_title.to_s
    @show_title = show_title
  end

  def show_title?
    @show_title
  end

  def css_link(*args)
    @css_links ||=[]
    @css_links +=args
  end

  def js_include(*args)
    @js_includes ||= []
    @js_includes += args
  end

  def ready_js(*args)
    @ready_js ||= []
    @ready_js += args
  end
end
