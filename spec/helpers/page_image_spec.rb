require 'rails_helper'

RSpec.describe Page::TemplateBinding, type: :helper do
  let(:binding) { described_class.new(view_helpers: helper, image_path: 'docs/example') }

  before do
    allow(helper).to receive(:vite_asset_path) { |path| "/#{path}" }
    allow(File).to receive(:file?).and_call_original
    allow(File).to receive(:file?).with(Rails.root.join('images/docs/example/screenshot-dark.png')).and_return(true)
  end

  it 'pairs canonical images with their dark siblings, preserving alt text, sizing, and alignment' do
    html = Nokogiri::HTML.fragment(binding.image('screenshot.png', size: '740x815', align: :center, class: 'example', alt: 'Workflow setup'))

    expect(html.css('img').map { |img| img['src'] }).to eq([
      '/images/example/screenshot.png', '/images/example/screenshot-dark.png'
    ])
    %w[light-only dark-only].each do |theme|
      variant = html.at_css(".#{theme}")
      expect(variant.at_css('img')['alt']).to eq('Workflow setup')
      expect(variant.at_css('img')['loading']).to eq('lazy')
      expect(variant.at_css('.example.responsive-image-container')).not_to be_nil
      expect(variant.at_css('[style="max-width: 740px; margin-inline: auto"]')).not_to be_nil
    end
  end

  it 'keeps centering styles inside the theme visibility wrapper for images without dimensions' do
    html = Nokogiri::HTML.fragment(binding.image('screenshot.png', align: :center, alt: 'Workflow setup'))

    expect(html.css('img').size).to eq(2)
    %w[light-only dark-only].each do |theme|
      variant = html.at_css(".#{theme}")
      expect(variant['style']).to be_nil
      expect(variant.at_css('img')['style']).to include('margin-inline: auto')
    end
  end

  it 'leaves unpaired images unchanged' do
    html = Nokogiri::HTML.fragment(binding.image('unpaired.png', width: 320, height: 160, alt: 'Unpaired'))

    expect(html.css('img').size).to eq(1)
    expect(html.at_css('img')['loading']).to be_nil
    expect(html.css('.light-only, .dark-only')).to be_empty
    expect(html.at_css('[style="max-width: 320px"]')).not_to be_nil
  end

  it 'does not add automatic variants to explicitly themed manual pairs' do
    %w[light-only dark-only].each do |theme|
      html = Nokogiri::HTML.fragment(binding.image('screenshot.png', class: theme, alt: 'Manual pair'))

      expect(html.css('img').size).to eq(1)
      expect(html.at_css('img')['class']).to eq(theme)
      expect(html.at_css('img')['loading']).to be_nil
    end
  end
end
