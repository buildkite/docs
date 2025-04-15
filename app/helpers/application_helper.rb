module ApplicationHelper
  def dashboard_path
    "/dashboard"
  end

  def buildkite_url
    @buildkite_url ||= Page::BuildkiteUrl.new
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

  def render_attribute_content(attribute)
    render(partial: "quick_reference/#{attribute}", formats: [:md]).to_json.html_safe
  end

  def logo_image_path
    image = 'logo.svg'

    # Pride month is June in The United States,
    # and this is generally acknowledged around the world
    # even if jurisdictions have their own dates. We also recognize
    # Mardi Gras in Sydney as Australia's main Pride festival in February.
    if DateTime.now.month == 6 || DateTime.now.month == 2
      image = 'logo-pride.svg'
    end

    image_path(image)
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

  def seo_canonical_url
    "https://buildkite.com#{request.path}"
  end
end
