require 'spec_helper'

RSpec.describe GeosparqlToGeojson::GeojsonValidator do
  context 'valid JSON' do
    let(:geojson_data) { JSON.parse(File.read('spec/fixtures/geojson/valid_geojson.json')) }
    subject { GeosparqlToGeojson::GeojsonValidator.new(geojson_data) }

    context '#errors' do
      it 'will not return any errors' do
        expect(subject.errors).to eq([])
      end
    end

    context '#valid?' do
      it 'will return true' do
        expect(subject.valid?).to eq(true)
      end
    end
  end

  context 'invalid JSON' do
    let(:geojson_data) { JSON.parse(File.read('spec/fixtures/geojson/invalid_geojson.json')) }
    subject { GeosparqlToGeojson::GeojsonValidator.new(geojson_data) }

    context '#errors' do
      it 'will not return any errors' do
        expect(subject.errors).not_to eq([])
      end
    end

    context '#valid?' do
      it 'will return true' do
        expect(subject.valid?).to eq(false)
      end
    end
  end
end
