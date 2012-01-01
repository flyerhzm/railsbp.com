module ApplicationHelper
  def notice_message
    flash_messages = []

    flash.each do |type, message|
      type = :success if type == :notice
      text = content_tag(:div, link_to("x", "#", :class => "close") + message, :class => "alert-message #{type}")
      flash_messages << text if message
    end

    flash_messages.join("\n").html_safe
  end

  def render_page(name)
    if page = Page.find_by_name(name)
      page.body.html_safe
    else
      ""
    end
  end
end
