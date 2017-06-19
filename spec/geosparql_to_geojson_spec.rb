require 'spec_helper'

RSpec.describe GeosparqlToGeojson do
  context '#convert_to_geojson' do
    let(:constituency){ double(:constituency, area: double(:area, longitude: '2.345', latitude: '53.678', polygon: [File.read('spec/fixtures/geosparql/single_polygon')])) }
    subject { described_class.convert_to_geojson(constituency) }

    it 'will convert GeoSparql' do
      require 'pry'; binding.pry
      expect(subject).to be_a(String)
      expect(JSON.parse(subject))
    end
  end
end
