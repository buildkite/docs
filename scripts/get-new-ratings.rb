require 'csv'

ratings_file = "#{Dir.home}/Downloads/ratings-export.csv"
output_file = __dir__+'/linear.csv'
processed_ratings_file = __dir__+'/emojicom-processed-ratings.txt'

# Ratings file format:
# id,date,device,country_code,rating,comment,email,url,client_ref

# Write CSV headings for Linear CSV import
output = CSV.open(output_file, "wb") do |line|
  line << ["Title", "Description", "Priority", "Status", "Assignee", "Labels"]
end

# Load the comments we've already seen
processed_comments = File.read(processed_ratings_file).split

CSV.foreach(ratings_file, force_quotes: true, headers: true, liberal_parsing: true) do |row|
  if not processed_comments.include? row[0] \
    and not row[5].to_s.empty? then
    output = CSV.open(output_file, "a", quote_empty: true, force_quotes: true) do |line|
      desc = row[5] + "\n\nCreated at: " + row[1] \
                                              + "\nID: " + row[0] \
                                              + "\nEmail: " +row[6].to_s \
                                              + "\nPage: " + row[7].to_s
      line << [row[5].split[0..10].join(' '), desc, "Low", "Todo", "", "Feedback"]

      # Log the comment we just output
      File.write(processed_ratings_file, row[0]+"\n", mode: "a")

      #puts [row[5].split[0..10].join(' '), desc, "Low", "Todo", "", "Feedback"]
    end
  end
end

# Run the linear cli import with the following options
#
# - API key
# - Linear CSV export
# - linear.csv
# - n
# - DOCS
# - n
# - n
# - [Unassigned]

# Commit the processed entries to avoid adding them again next time!

# Feedback tickets are visible https://linear.app/buildkite/view/0fe32d51-f7bb-445c-8bf2-dd8fd0cb281d
