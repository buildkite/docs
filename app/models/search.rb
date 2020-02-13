class Search
  class << self
    def all_documents
      mdfiles = File.join("**", "*.md.erb")
      Dir.glob(mdfiles)
    end

    def find_word(query)
      data = []
      docs = Search.all_documents
      docs.each do |doc|
        File.open(doc) do |f|
          f.any? do |line|
            if line.include?(query)
              # link = remove page and md.erb from doc
              data << [doc, line]
            end
          end
        end
      end
      return data
    end
  end
end
