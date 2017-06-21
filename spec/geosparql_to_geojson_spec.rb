require 'spec_helper'

RSpec.describe GeosparqlToGeojson do
  it 'has a version number' do
    expect(GeosparqlToGeojson::VERSION).not_to be_nil
  end
  # context '#convert_to_geojson' do
  #   let(:constituency){ double(:constituency, area: double(:area, longitude: '2.345', latitude: '53.678', polygon: [File.read('spec/fixtures/geosparql/single_polygon')])) }
  #   subject { described_class.convert_to_geojson(constituency) }

  #   it 'will convert GeoSparql' do
  #     expect(subject).to be_a(String)
  #     # expect(JSON.parse(subject))
  #   end
  # end

  context '#verify_grom_node' do
    context 'data is ntriple data' do
      let(:ntriple_data){ File.read('spec/fixtures/geosparql/ntriple.nt') }
      subject { described_class.verify_grom_node(ntriple_data) }

      it 'transform ntriple data to grom objects' do
        expect(subject).to be_a(Array)
        expect(subject.first).to be_a(Grom::Node)
      end
    end
  end
end
