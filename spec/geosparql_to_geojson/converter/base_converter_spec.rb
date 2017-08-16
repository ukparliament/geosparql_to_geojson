# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GeosparqlToGeojson::Converter::BaseConverter do
  context 'n-triple data' do
    let(:geosparql_data) { File.read('spec/fixtures/geosparql/ntriple.nt') }
    subject { described_class.new(geosparql_data, {}, false).convert.geojson }
    let(:parsed_json) { JSON.parse(subject) }

    it 'will return a GeoJson object' do
      expect(described_class.new(geosparql_data, {}, true).convert).to be_a(GeosparqlToGeojson::GeoJson)
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
    let(:values) { '2.123 3.234' }
    let(:converter) { described_class.new(values, {}, true) }

    context 'point' do
      it 'formats the value string' do
        expect(converter.send(:format_data, values, :Point)).to eq([3.234, 2.123])
      end

      context 'do not reverse' do
        let(:converter) { described_class.new(values, {}, false) }
        it 'will not reverse values' do
          expect(converter.send(:format_data, values, :Point)).to eq([2.123, 3.234])
        end
      end
    end

    context 'larger dataset' do
      let(:values) { ['1.23 2.34 3.45 4.56 5.67 6.78'] }

      it 'formats the value string' do
        expect(converter.send(:format_data, values, :Polygon)).to eq([[[6.78, 5.67], [4.56, 3.45], [2.34, 1.23]]])
      end

      context 'odd number of values' do
        let(:values) { ['1.23 2.34 3.45 4.56 5.67'] }

        it 'formats the value string' do
          expect(converter.send(:format_data, values, :Polygon)).to eq([[[5.67, 4.56], [3.45, 2.34], [1.23]]])
        end
      end
    end
  end

  context '#convert_key_to_correct_format' do
    let(:values) { '2.123 3.234' }
    let(:converter) { described_class.new(values, {}, true) }

    it 'will correctly format key' do
      expect(converter.send(:convert_key_to_correct_format, 'muLtiline')).to eq(:Multiline)
    end
  end

  context '#populate_data_hash' do
    before(:each) do
      converter.instance_variable_set(:@geosparql_values_by_type, {})
    end

    context 'correct data' do
      let(:values) { ['Linestring((2.345 2.32323),(12.3232, 5.34343))'] }
      let(:converter) { described_class.new(values, {}, true) }

      it 'will correctly populate data hash' do
        converter.send(:populate_data_hash, [['Polygon', '12.123']])
        expect(converter.instance_variable_get(:@geosparql_values_by_type)).to eq(Polygon: ['12.123'])
      end
    end

    context 'data is missing a key' do
      let(:values) { ['Linestring((2.345 2.32323),(12.3232, 5.34343))'] }
      let(:converter) { described_class.new(values, {}, true) }

      it 'will correctly populate data hash' do
        converter.send(:populate_data_hash, [['Polygon', '12.123'],[nil, '321.12']])
        expect(converter.instance_variable_get(:@geosparql_values_by_type)).to eq(Polygon: ['12.123', '321.12'])
      end

    end
  end

  context 'properties' do
    let(:properties_data) { { name: 'Test Name', start_date: '21-12-2008 10:51', end_date: nil } }
    let(:values) { 'Point(2.123 3.234)' }
    let(:converted_data) { described_class.new(values, properties_data, true).convert }

    it 'will format properties data' do
      expect(JSON.parse(converted_data.geojson)['features'][0]['properties']).to eq('name' => 'Test Name', 'start_date' => '21-12-2008 10:51', 'end_date' => nil)
    end
  end

  context 'single polygon' do
    let(:values) { File.read('spec/fixtures/geosparql/single_polygon') }
    subject { described_class.new(values, {}, false).convert }
    let(:parsed_json) { JSON.parse(subject.geojson) }

    it 'will return a GeoJson object' do
      expect(subject).to be_a(GeosparqlToGeojson::GeoJson)
    end

    it 'has a single polygon' do
      expect(parsed_json['features'][0]['geometry']['coordinates']).to be_a(Array)
      expect(parsed_json['features'][0]['geometry']['type']).to eq('Polygon')
    end

    it 'has polygon data' do
      expect(parsed_json['features'][0]['geometry']['coordinates'].empty?).to eq(false)
    end
  end

  context 'multiple polygons, linestrings, points and holes' do
    let(:values) { File.read('spec/fixtures/geosparql/multiple_polygons_linestrings_points_and_holes') }
    subject { described_class.new(values, {}, false).convert }
    let(:parsed_json) { JSON.parse(subject.geojson) }

    it 'will return a GeoJson object' do
      expect(subject).to be_a(GeosparqlToGeojson::GeoJson)
    end

    it 'will generate valid GeoJSON' do
      expect(GeosparqlToGeojson::GeojsonValidator.new(subject.geojson).valid?).to eq(true)
    end

    it 'converts 9 features' do
      expect(parsed_json['features'].count).to eq(9)
    end

    it 'has 4 polygons' do
      expect(parsed_json['features'][0]['geometry']['type']).to eq('Polygon')
      expect(parsed_json['features'][1]['geometry']['type']).to eq('Polygon')
      expect(parsed_json['features'][2]['geometry']['type']).to eq('Polygon')
      expect(parsed_json['features'][3]['geometry']['type']).to eq('Polygon')
    end

    it 'has polygons data' do
      parsed_json['features'].each do |polygon|
        expect(polygon['geometry']['coordinates'].empty?).to eq(false)
      end
    end

    context 'linestrings' do
      it 'has 2 linestrings' do
        expect(parsed_json['features'][4]['geometry']['type']).to eq('LineString')
        expect(parsed_json['features'][5]['geometry']['type']).to eq('LineString')
      end
    end

    context 'points' do
      it 'has 3 points' do
        expect(parsed_json['features'][6]['geometry']['type']).to eq('Point')
        expect(parsed_json['features'][7]['geometry']['type']).to eq('Point')
        expect(parsed_json['features'][8]['geometry']['type']).to eq('Point')
      end
    end

    context 'holes within polygons' do
      it 'will format polygon and hole data correctly' do
        expect(parsed_json['features'][0]['geometry']['coordinates'].count).to eq(3)
        expect(parsed_json['features'][0]['geometry']['coordinates'][0]).to include([-2.669248580932617, 52.96187505907603])
        expect(parsed_json['features'][0]['geometry']['coordinates'][1]).to include([-2.065000534057617, 53.00486789706824])
        expect(parsed_json['features'][0]['geometry']['coordinates'][2]).to include([-1.7463970184326172, 52.43926935464697])
      end
    end
  end

  context 'North East Somerset' do
    let(:values) { File.read('spec/fixtures/geosparql/north_east_somerset.nt') }
    subject { described_class.new(values, {}, false).convert }
    let(:parsed_json) { JSON.parse(subject.geojson) }


    it 'will return a GeoJson object' do
      expect(subject).to be_a(GeosparqlToGeojson::GeoJson)
    end

    it 'will generate valid GeoJSON' do
      expect(GeosparqlToGeojson::GeojsonValidator.new(subject.geojson).valid?).to eq(true)
    end

    it 'converts 1 feature' do
      expect(parsed_json['features'].count).to eq(1)
    end

    context 'polygon with hole' do
      it 'has two coordinates' do
        expect(parsed_json['features'][0]['geometry']['coordinates'].count).to eq(2)
      end

      context 'polygon' do
        it 'has correct polygon data' do
          expect(parsed_json['features'][0]['geometry']['coordinates'][0][0]).to eq([-2.69426464563, 51.38006394591])
        end
      end

      context 'hole' do
        it 'has correct hole data' do
          expect(parsed_json['features'][0]['geometry']['coordinates'][1][0]).to eq([-2.31833567852, 51.3639491434])
        end
      end
    end
  end
end
