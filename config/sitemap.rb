# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "http://www.example.com"
SitemapGenerator::Sitemap.sitemaps_path = "docs/"

SitemapGenerator::Sitemap.create do
  Page.all.each do |page|
    add page.path, :lastmod => page.updated_at
  end
end
