# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GeosparqlToGeojson::Converter do
  context 'single polygon' do
    let(:geosparql_data) { File.read('spec/fixtures/geosparql/single_polygon') }
    subject { GeosparqlToGeojson::Converter.new(geosparql_data, {}, false).convert.geojson }
    let(:parsed_json) { JSON.parse(subject) }

    it 'will return a GeoJson object' do
      expect(GeosparqlToGeojson::Converter.new(geosparql_data, {}, false).convert).to be_a(GeosparqlToGeojson::GeoJson)
    end

    it 'will generate valid GeoJSON' do
      expect(GeosparqlToGeojson::GeojsonValidator.new(subject).valid?).to eq(true)
    end

    it 'has a single polygon' do
      expect(parsed_json['features'][0]['geometry']['coordinates']).to be_a(Array)
      expect(parsed_json['features'][0]['geometry']['type']).to eq('Polygon')
    end

    it 'has polygon data' do
      expect(parsed_json['features'][0]['geometry']['coordinates'].empty?).to eq(false)
    end
  end

  context 'multiple polygons' do
    let(:geosparql_data) { File.read('spec/fixtures/geosparql/multiple_polygons') }
    subject { GeosparqlToGeojson::Converter.new(geosparql_data, {}, false).convert.geojson }
    let(:parsed_json) { JSON.parse(subject) }

    it 'will return a GeoJson object' do
      expect(GeosparqlToGeojson::Converter.new(geosparql_data, {}, false).convert).to be_a(GeosparqlToGeojson::GeoJson)
    end

    it 'will generate valid GeoJSON' do
      expect(GeosparqlToGeojson::GeojsonValidator.new(subject).valid?).to eq(true)
    end

    it 'has two polygons' do
      expect(parsed_json['features'].count).to eq(3)
      expect(parsed_json['features'][1]['geometry']['type']).to eq('Polygon')
      expect(parsed_json['features'][2]['geometry']['type']).to eq('Polygon')
    end

    it 'has polygons data' do
      parsed_json['features'].each do |polygon|
        expect(polygon['geometry']['coordinates'].empty?).to eq(false)
      end
    end
  end

  context 'n-triple data' do
    let(:geosparql_data) { File.read('spec/fixtures/geosparql/ntriple.nt') }
    subject { GeosparqlToGeojson::Converter.new(geosparql_data, {}, false).convert.geojson }
    let(:parsed_json) { JSON.parse(subject) }

    it 'will return a GeoJson object' do
      expect(GeosparqlToGeojson::Converter.new(geosparql_data, {}, true).convert).to be_a(GeosparqlToGeojson::GeoJson)
    end

    it 'will generate valid GeoJSON' do
      expect(GeosparqlToGeojson::GeojsonValidator.new(subject).valid?).to eq(true)
    end

    it 'has four features' do
      expect(parsed_json['features'].count).to eq(4)
    end

    it 'has two polygons' do
      expect(parsed_json['features'][2]['geometry']['type']).to eq('Polygon')
      expect(parsed_json['features'][3]['geometry']['type']).to eq('Polygon')
    end

    it 'has two points' do
      expect(parsed_json['features'][0]['geometry']['type']).to eq('Point')
      expect(parsed_json['features'][1]['geometry']['type']).to eq('Point')
    end
  end

  context '#format_data' do
    let(:values) { ['2.123 3.234'] }
    let(:converter) { GeosparqlToGeojson::Converter.new(values, {}, true) }

    context 'point' do
      it 'formats the value string' do
        expect(converter.format_data(values, :Point)).to eq([3.234, 2.123])
      end

      context 'do not reverse' do
        let(:converter) { GeosparqlToGeojson::Converter.new(values, {}, false) }
        it 'will not reverse values' do
          expect(converter.format_data(values, :Point)).to eq([2.123, 3.234])
        end
      end
    end

    context 'larger dataset' do
      let(:values) { ['1.23 2.34 3.45 4.56 5.67 6.78'] }

      it 'formats the value string' do
        expect(converter.format_data(values, :Polygon)).to eq([[[6.78, 5.67], [4.56, 3.45], [2.34, 1.23]]])
      end

      context 'odd number of values' do
        let(:values) { ['1.23 2.34 3.45 4.56 5.67'] }

        it 'formats the value string' do
          expect(converter.format_data(values, :Polygon)).to eq([[[5.67, 4.56], [3.45, 2.34], [1.23]]])
        end
      end
    end
  end

  context 'properties' do
    let(:properties_data) { { name: 'Test Name', start_date: '21-12-2008 10:51', end_date: nil } }
    let(:values) { 'Point(2.123 3.234)' }
    let(:converted_data) { GeosparqlToGeojson::Converter.new(values, properties_data, true).convert }

    it 'will format properties data' do
      expect(JSON.parse(converted_data.geojson)['features'][0]['properties']).to eq('name' => 'Test Name', 'start_date' => '21-12-2008 10:51', 'end_date' => nil)
    end
  end
end
