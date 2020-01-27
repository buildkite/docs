module ApplicationHelper
  def dashboard_path
    "/dashboard"
  end

  def sidebar_link_to(name, path, options = {})
    url = "/docs/#{path}"

    options[:class] = [options[:class]].flatten.compact
    options[:class] << 'Docs__nav__sub-nav__item__link Link--on-white Link--no-underline'
    options[:class] << "active" if current_page?(url)

    link_to(name, url, options)
  end

  def open_source_url
    # This dirty hack grabs the filename for the current ERB file being rendered
    view_path = @page.instance_variable_get(:@filename)

    view_file = view_path.to_s.
                  sub(Rails.root.to_s, '').
                  # /app/views/pages are a symlink to /pages at the moment, and you can't link
                  # to them on GitHub. So until we remove the symlink, we'll just rewrite the
                  # URL so it points to the /pages version.
                  sub('/app/views/pages', '/pages')
  
    "https://github.com/buildkite/docs/tree/master#{view_file}"
  end
end
