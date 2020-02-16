class Search
  class << self
    def all_documents
      mdfiles = File.join("**", "*.md.erb")
      Dir.glob(mdfiles)
    end

    def make_link_pretty(doc)
      remove_page = "pages/"
      remove_file_tag = ".md.erb"
      doc = doc.sub(remove_page, '')
      doc.chomp(remove_file_tag)
    end

    def find_word(query)
      data = []
      docs = Search.all_documents
      docs.each do |doc|
        File.open(doc) do |f|
          f.any? do |line|
            if line.include?(query)
              link = make_link_pretty(doc)
              data << {:link => link, :content => line}
            end
          end
        end
      end
      return data
    end
  end
end
