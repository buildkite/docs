module ApplicationHelper
  def sidebar_link_to(name, path, options = {})
    url = "/docs/#{path}"

    options[:class] = [options[:class]].flatten.compact
    options[:class] << 'Docs__nav__sub-nav__item__link Link--on-white Link--no-underline'
    options[:class] << "active" if current_page?(url)

    link_to(name, url, options)
  end

  def open_source_url(basename = nil)
    if basename
      "https://github.com/buildkite/docs/tree/master/pages/#{basename}.md.erb"
    else
      "TODO"
    end
  end
end
