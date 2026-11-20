require 'rails_helper'

RSpec.describe 'Theme screenshot pairs' do
  Dir[Rails.root.join('images/**/*-dark.png')].sort.each do |dark|
    it "has a matching light image with the same dimensions for #{dark.delete_prefix("#{Rails.root}/")}" do
      light = dark.sub(/-dark\.png\z/, '.png')
      light = dark.sub(/-dark\.png\z/, '-light.png') unless File.file?(light)

      expect(File.file?(light)).to be(true), "Missing light counterpart for #{dark}"
      # PNG IHDR stores width and height as two big-endian 32-bit integers.
      expect(File.binread(dark, 24)[16, 8].unpack('NN')).to eq(File.binread(light, 24)[16, 8].unpack('NN'))
    end
  end
end
