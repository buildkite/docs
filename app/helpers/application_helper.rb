module ApplicationHelper
  def dashboard_path
    "/dashboard"
  end

  def nav_path(path)
    if path =~ URI::regexp
      path
    elsif path =~ URI::MailTo::EMAIL_REGEXP
      "mailto:#{path}"
    else
      docs_page_path(path)
    end
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

    "https://github.com/buildkite/docs/edit/main#{view_file}"
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

  def logo_image_url
    image = 'logo.svg'

    # Pride month is June in The United States,
    # and this is generally acknowledged around the world
    # even if jurisdictions have their own dates. We also recognize
    # Mardi Gras in Sydney as Australia's main Pride festival in February.
    if DateTime.now.month == 6 || DateTime.now.month == 2 || DateTime.now.month == 3 # Remove case for March on March 6
      image = 'logo-pride.svg'
    end

    image_url(image)
  end

  def top_level_nav_item_name(path)
    name = path.split("/")[0]

    if name === "apis"
      "APIs"
    else
      name = name.gsub("-", " ")
      name.titleize
    end
  end
end
