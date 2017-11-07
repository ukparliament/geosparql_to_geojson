# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GeosparqlToGeojson::Converter::PolygonConverter do
  let(:values) { eval(IO.read('spec/fixtures/method_outputs/polygon_data')) }
  subject { described_class.new({}, values) }

  context '#format_data' do
    it 'will format @values strings correctly' do
      expect(subject.send(:format_data)).to eq(eval(IO.read('spec/fixtures/method_outputs/format_data')))
    end
  end

  context '#split_into_polygons_and_holes' do
    let(:format_data_output_values) { eval(IO.read('spec/fixtures/method_outputs/format_data')) }
    subject { described_class.new({}, values) }

    before(:each) do
      subject.instance_variable_set(:@values, format_data_output_values)
      subject.send(:split_into_polygons_and_holes)
    end

    it 'will separate holes' do
      expect(subject.instance_variable_get(:@holes)).to eq(eval(IO.read('spec/fixtures/method_outputs/holes')))
    end

    it 'will sparate polygons' do
      expect(subject.instance_variable_get(:@polygons)).to eq(eval(IO.read('spec/fixtures/method_outputs/polygons')))
    end
  end

  context '#hole?' do
    context 'array is NOT a hole' do
      let(:hole_values) { eval(IO.read('spec/fixtures/method_outputs/polygons')).first }
      it 'will return false' do
        expect(subject.send(:hole?, hole_values)).to eq(false)
      end
    end

    context 'array IS a hole' do
      let(:hole_values) { eval(IO.read('spec/fixtures/method_outputs/holes')).first }
      it 'will return true' do
        expect(subject.send(:hole?, hole_values)).to eq(true)
      end
    end
  end

  context '#matches_holes_to_polygons' do
    before do
      subject.instance_variable_set(:@polygons, eval(IO.read('spec/fixtures/method_outputs/polygons')))
      subject.instance_variable_set(:@holes, eval(IO.read('spec/fixtures/method_outputs/holes')))
      subject.send(:match_holes_to_polygons)
    end

    it 'will match the correct holes to polygons' do
      expect(subject.instance_variable_get(:@matches)).to eq(0 => [0, 1], 2 => [2])
    end
  end

  context '#find_min_and_max_axis' do
    before do
      subject.send(:set_min_and_max_axis, eval(IO.read('spec/fixtures/method_outputs/polygons')).first)
    end

    it 'will set the min and max axis' do
      expect(subject.instance_variable_get(:@x_min)).to eq([-2.850522994995117])
      expect(subject.instance_variable_get(:@y_min)).to eq([52.13011607781287])
      expect(subject.instance_variable_get(:@x_max)).to eq([-1.0322856903076172])
      expect(subject.instance_variable_get(:@y_max)).to eq([53.27506837459297])
    end
  end

  context '#set_min_and_max_to_first_value' do
    before do
      subject.instance_variable_set(:@x_min, [1, 2])
      subject.instance_variable_set(:@y_min, [3, 4])
      subject.instance_variable_set(:@x_max, [5, 6])
      subject.instance_variable_set(:@y_max, [7, 8])

      subject.send(:set_min_and_max_to_first_value)
    end

    it 'will set values to an array containing its first value' do
      expect(subject.instance_variable_get(:@x_min)).to eq([1])
      expect(subject.instance_variable_get(:@y_min)).to eq([3])
      expect(subject.instance_variable_get(:@x_max)).to eq([5])
      expect(subject.instance_variable_get(:@y_max)).to eq([7])
    end
  end

  context '#reset_min_and_max_instance_variables' do
    before do
      subject.instance_variable_set(:@x_min, [1, 2])
      subject.instance_variable_set(:@y_min, [3, 4])
      subject.instance_variable_set(:@x_max, [5, 6])
      subject.instance_variable_set(:@y_max, [7, 8])

      subject.send(:reset_min_and_max_instance_variables)
    end

    it 'will set axis variables to nil' do
      expect(subject.instance_variable_get(:@x_min)).to eq(nil)
      expect(subject.instance_variable_get(:@y_min)).to eq(nil)
      expect(subject.instance_variable_get(:@x_max)).to eq(nil)
      expect(subject.instance_variable_get(:@y_max)).to eq(nil)
    end
  end

  context '#format_polygons_with_holes' do
    before do
      subject.instance_variable_set(:@formatted_polygon_array, [])
      subject.instance_variable_set(:@matches, 0 => [0, 1], 2 => [2])
      subject.instance_variable_set(:@polygons, eval(IO.read('spec/fixtures/method_outputs/polygons')))
      subject.instance_variable_set(:@holes, eval(IO.read('spec/fixtures/method_outputs/holes')))
      subject.send(:format_polygons_with_holes)
    end

    it 'will correctly format polygons that contain holes' do
      expect(subject.instance_variable_get(:@formatted_polygon_array)).to eq(eval(IO.read('spec/fixtures/method_outputs/format_polygons_with_holes')))
    end
  end

  context '#format_polygons_without_holes' do
    before do
      subject.instance_variable_set(:@polygons, [[1, 2], [3, 4]])
      subject.instance_variable_set(:@formatted_polygon_array, [])
      subject.send(:format_polygons_without_holes)
    end

    it 'will add polygons to @formatted_polygon_array' do
      expect(subject.instance_variable_get(:@formatted_polygon_array)).to eq([[[1, 2]], [[3, 4]]])
    end
  end

  context '#remove_polygons_with_holes' do
    before do
      subject.instance_variable_set(:@matches, 0 => [0, 1], 2 => [2])
      subject.instance_variable_set(:@polygons, eval(IO.read('spec/fixtures/method_outputs/polygons')))
      subject.send(:remove_polygons_with_holes)
    end

    it 'will remove correct values from @polygons' do
      expect(subject.instance_variable_get(:@polygons).count).to eq(2)
      expect(subject.instance_variable_get(:@polygons)[0]).to eq(eval(IO.read('spec/fixtures/method_outputs/polygons'))[1])
      expect(subject.instance_variable_get(:@polygons)[1]).to eq(eval(IO.read('spec/fixtures/method_outputs/polygons'))[3])
    end
  end

  context '#add_formatted_polygons_to_data_hash' do
    before do
      subject.instance_variable_set(:@geosparql_values_by_type, {})
      subject.instance_variable_set(:@formatted_polygon_array, [1, 2, 3])
      subject.send(:add_formatted_polygons_to_data_hash)
    end

    it 'will populate @geosparql_values_by_type with formatted polygons' do
      expect(subject.instance_variable_get(:@geosparql_values_by_type)).to eq(Polygon: [1, 2, 3])
    end
  end
end
