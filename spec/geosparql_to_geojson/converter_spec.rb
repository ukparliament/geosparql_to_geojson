require 'spec_helper'

RSpec.describe GeosparqlToGeojson::Converter do
  context 'single polygon' do
    let(:constituency){ double(:constituency, area: double(:area, longitude: '2.345', latitude: '53.678', polygon: [File.read('spec/fixtures/geosparql/single_polygon')])) }
    subject { GeosparqlToGeojson::Converter.new(constituency).convert }
    let(:parsed_json){ JSON.parse(subject) }

    it 'will generate valid GeoJSON' do
      expect(GeosparqlToGeojson::GeojsonValidator.new(subject).valid?).to eq(true)
    end

    it 'has latitude and longitude' do
      expect(parsed_json['features'][0]['geometry']['coordinates']).to eq([2.345, 53.678])
    end

    it 'has one polygon' do
      expect(parsed_json['features'].count).to eq(2)
      expect(parsed_json['features'][1]['geometry']['type']).to eq('Polygon')
    end
  end

  context 'multiple polygons' do
    let(:constituency){ double(:constituency, area: double(:area, longitude: '2.345', latitude: '53.678', polygon: File.read('spec/fixtures/geosparql/multiple_polygons').split(', '))) }
    subject { GeosparqlToGeojson::Converter.new(constituency).convert }
    let(:parsed_json){ JSON.parse(subject) }

    it 'will generate valid GeoJSON' do
      expect(GeosparqlToGeojson::GeojsonValidator.new(subject).valid?).to eq(true)
    end

    it 'has latitude and longitude' do
      expect(parsed_json['features'][0]['geometry']['coordinates']).to eq([2.345, 53.678])
    end

    it 'has two polygons' do
      expect(parsed_json['features'].count).to eq(3)
      expect(parsed_json['features'][1]['geometry']['type']).to eq('Polygon')
      expect(parsed_json['features'][2]['geometry']['type']).to eq('Polygon')
    end
  end
end
