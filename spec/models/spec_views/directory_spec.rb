# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SpecViews::Directory do
  let(:path) { Pathname.new(Dir.mktmpdir) }
  let(:directory) { described_class.new(path) }

  after { FileUtils.remove_entry(path) }

  describe '#http_method' do
    it 'extracts the method from the description' do
      directory.write_meta('Articles GET /articles renders the listing', :request, :html)
      expect(directory.http_method).to eq 'GET'
    end
  end

  describe '#spec_type' do
    it 'reads the type from meta.txt' do
      directory.write_meta('Articles GET /articles renders the listing', :feature, :html)
      expect(directory.spec_type).to be_feature
    end

    it 'falls back to response without meta.txt' do
      expect(directory.spec_type).to be_response
      expect(directory.spec_type).not_to be_feature
    end
  end
end
