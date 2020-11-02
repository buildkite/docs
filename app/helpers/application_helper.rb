module ApplicationHelper
  def dashboard_path
    "/dashboard"
  end

  def sidebar_link_to(name, path, options = {})
    full_path = docs_page_path(path)

    options[:class] = [options[:class]].flatten.compact
    options[:class] << 'Docs__nav__sub-nav__item__link Link--on-white Link--no-underline'
    options[:class] << "active" if current_page?(full_path)

    link_to name, full_path, options
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

  def agent_installers
    @agent_installers ||= Psych.safe_load(File.read(Rails.root.join('app/data/agent_installers.yml')))
  end

  def algolia_api_key
    ENV.fetch("ALGOLIA_API_KEY", "unknown")
  end

  def algolia_index_name
    ENV.fetch("ALGOLIA_INDEX_NAME","unknown")
  end

  def algolia_app_id
    ENV.fetch("ALGOLIA_APP_ID", "unknown")
  end

  def render_attribute_content(attribute)
    render(partial: "quick_reference/#{attribute}", formats: [:md]).to_json.html_safe
  end
end
