module ButtonHelper

  def button(children, url, has_right_arrow = false)
    if children && url
      inner_html = 
      if has_right_arrow
        content_tag(:span, children) +
        content_tag(:span, "", class: "Button__right-arrow")
      else
        children
      end

      link_to(inner_html, url, class: "Button")
    end
  end

end
