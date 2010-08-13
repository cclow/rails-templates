module AnytimeHelper
  def anytime_js(div, format = "%Y-%m-%d %H:%i")
    opts = { :format => format }
    js_include('anytime.js')
    content_for :js do
      javascript_tag %Q|$('##{div}').AnyTime_picker(#{opts.to_json});|
    end
  end
end
