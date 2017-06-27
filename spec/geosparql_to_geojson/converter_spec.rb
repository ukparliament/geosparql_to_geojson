require 'spec_helper'

RSpec.describe GeosparqlToGeojson::Converter do
  context 'single polygon' do
    let(:geosparql_data){ File.read('spec/fixtures/geosparql/single_polygon') }
    subject { GeosparqlToGeojson::Converter.new(geosparql_data).convert }
    let(:parsed_json){ JSON.parse(subject) }

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
    let(:geosparql_data){ File.read('spec/fixtures/geosparql/multiple_polygons') }
    subject { GeosparqlToGeojson::Converter.new(geosparql_data).convert }
    let(:parsed_json){ JSON.parse(subject) }

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
    let(:geosparql_data){ File.read('spec/fixtures/geosparql/ntriple.nt') }
    subject { GeosparqlToGeojson::Converter.new(geosparql_data).convert }
    let(:parsed_json){ JSON.parse(subject) }

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

  context '#format_point_data' do
    let(:values){ ['2.123 3.234'] }
    let(:converter){ GeosparqlToGeojson::Converter.new(values) }

    it 'formats the value string' do
      expect(converter.format_point_data(values)).to eq([2.123, 3.234])
    end
  end

  context '#format_linestring_data' do
    let(:values){ ['2.123 3.234'] }
    let(:converter){ GeosparqlToGeojson::Converter.new(values) }

    it 'formats the value string' do
      expect(converter.format_linestring_data(values)).to eq([[2.123, 3.234]])
    end
  end

  context '#format_complext_coordinates' do
    let(:values){ ['2.123 3.234'] }
    let(:converter){ GeosparqlToGeojson::Converter.new(values) }

    it 'formats the value string' do
      expect(converter.format_complext_coordinates(values)).to eq([[[2.123, 3.234]]])
    end

    context 'larger dataset' do
      let(:values){ ['1.23 2.34 3.45 4.56 5.67 6.78'] }

      it 'formats the value string' do
        expect(converter.format_complext_coordinates(values)).to eq([[[5.67, 6.78], [3.45, 4.56], [1.23, 2.34]]])
      end

      context 'odd number of values' do
        let(:values){ ['1.23 2.34 3.45 4.56 5.67'] }

        it 'formats the value string' do
          expect(converter.format_complext_coordinates(values)).to eq([[[5.67], [3.45, 4.56], [1.23, 2.34]]])
        end
      end
    end
  end
end

