require 'rails_helper'

RSpec.describe Search, type: :model do
  context 'returns all documents from pages directory' do
    it 'expect v2.md.erb to be returned' do
      expect(Search.all_documents).to include("pages/agent/v2.md.erb")
    end

    it 'gets all 130 documents in pages directory' do
      expect(Search.all_documents.count).to eq(130)
    end

    it 'makes sure there are documents in pages directory' do
      expect(Search.all_documents.count).to_not eq(0)
    end
  end
end
