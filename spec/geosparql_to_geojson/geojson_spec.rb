# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GeosparqlToGeojson::GeoJson do
  context '#validate' do
    subject { described_class.new(JSON.parse(File.read('spec/fixtures/geojson/valid_geojson.json'))) }

    it 'will return a GeoJsonValidator object' do
      expect(subject.validate).to be_a(GeosparqlToGeojson::GeojsonValidator)
    end
  end
end
