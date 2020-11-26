# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

# Update test search index with whatever is in config/algolia.json

task :update_test_index do
   sh 'docker run -it --env-file=.env -e "CONFIG=$(cat config/algolia.json | sed "s/prod_docs/test_docs/" | jq -r tostring)" algolia/docsearch-scraper'
end