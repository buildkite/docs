# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://buildkite.com"
SitemapGenerator::Sitemap.sitemaps_path = "docs/"
SitemapGenerator::Sitemap.include_root = false

SitemapGenerator::Sitemap.create do
  add "/docs", :changefreq => "weekly", :priority => 0.9

  Page.all.each do |page|
    add page.path, :lastmod => page.updated_at, :changefreq => "monthly", :priority => 0.5
  end
end
