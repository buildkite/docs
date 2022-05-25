module ButtonHelper

  def button(children, url, has_right_arrow = false)
    link_to(
      if has_right_arrow
        children.html_safe +
        content_tag(:span, "", class: "Button__right-arrow", aria: { "hidden": true })
      else
        children.html_safe
      end,
      url,
      class: "Button"
    )
  end

end
