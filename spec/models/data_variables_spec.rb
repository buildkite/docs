require "rails_helper"

RSpec.describe DataVariables do
  context ".entries" do
    it "excludes *.schema.yml files" do
      files = ["notification.yml", "tiles.schema.yml"]

      entries = described_class.entries(files)

      expect(entries).to eq ["notification.yml"]
    end

    it "accepts .yaml and .yml files" do
      files = ["notification.yml", "agent_attributes.yaml"]

      entries = described_class.entries(files)

      expect(entries).to eq files
    end

    it "excludes any other files that are not in yml format" do
      files = ["notification.yml", "other_file_format.erb"]

      entries = described_class.entries(files)

      expect(entries).to eq ["notification.yml"]
    end
  end

  context ".set" do
    it "sets env variables for all the data/*.yml files" do
      data_variables = described_class.set

      expect(NOTIFICATION).to be_present
    end
  end
end
