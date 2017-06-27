require 'spec_helper'

RSpec.describe GeosparqlToGeojson do
  it 'has a version number' do
    expect(GeosparqlToGeojson::VERSION).not_to be_nil
  end

  context '#convert_to_geojson' do
    let(:ntriple_data){ File.read('spec/fixtures/geosparql/generic_data.nt') }
    subject { described_class.convert_to_geojson(ntriple_data) }
    it 'will convert data to GeoJSON' do
      expect(JSON.parse(subject)['features'][0]['type']).to eq('Feature')
      expect(JSON.parse(subject)['features'][0]['geometry']['type']).to eq('Point')
    end

    it 'will create valid GeoJSON' do
      expect(GeosparqlToGeojson::GeojsonValidator.new(subject).valid?).to eq(true)
    end
  end
end
