class Page::Button
  
  def initialize(children, url, has_right_arrow = false)
    @children = children
    @url = url
    @has_right_arrow = has_right_arrow
  end

  def render
    right_arrow_html = @has_right_arrow ? %{<span aria-hidden class="Button__right-arrow"></span>} : ''
    %{<a class="Button" href="#{@url}">#{@children}#{right_arrow_html}</a>}
  end

end
