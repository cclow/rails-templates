module AutoFocusHelper
  def auto_focus(div)
    ready_js("$('##{div}').addClass('auto-focus');")
    ready_js("$('.auto-focus:first').focus();")
  end
end
