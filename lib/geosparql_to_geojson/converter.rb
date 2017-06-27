require 'json'

module GeosparqlToGeojson
  class Converter
    GEOMETRY_TYPES = %w(Point Multipoint LineString Multiline Polygon MultiPolygon GeometryCollection).freeze

    def initialize(geosparql_data)
      @geosparql = geosparql_data
    end

    def convert
      collect_geosparql_data
    end

    # create hash of each geometry type and it's values
    def collect_geosparql_data
      @data_store = {}
      GEOMETRY_TYPES.each do |geometry_type|
        geosparql_data_match = @geosparql.scan(/#{geometry_type}\(+(.*?)\)+/i)
        @data_store[geometry_type.to_sym] = geosparql_data_match unless geosparql_data_match.empty?
      end

      format_geosparql_data
    end

    # split values into arrays and convert them to floats
    def format_geosparql_data
      @data_store.keys.each do |key|
        @data_store[key.to_sym].map! do |values|
          if key == :Point
            format_point_data(values)
          elsif key == :LineString
            format_linestring_data(values)
          else
            format_complext_coordinates(values)
          end
        end
      end

      generate_hash_from_values
    end

    def format_point_data(values)
      values[0].split(/[\s]|[,]/).map!(&:to_f)
    end

    def format_linestring_data(values)
      values[0].split(/[\s]|[,]/).map!(&:to_f).each_slice(2).to_a.reverse
    end

    def format_complext_coordinates(values)
      [values[0].split(/[\s]|[,]/).map!(&:to_f).each_slice(2).to_a.reverse]
    end

    def generate_hash_from_values
      @data_hash_array = []
      @data_store.keys.each do |key|
        @data_store[key.to_sym].each do |data|
           @data_hash_array << generate_feature_hash({ type: key.to_s, coordinates: data })
        end
      end
      generate_geojson_from_hash
    end

    def generate_feature_hash(data_hash)
      {
        type: 'Feature',
        geometry: data_hash,
        properties: {}
      }
    end

    def generate_geojson_from_hash
      data_hash = {
                    type: 'FeatureCollection',
                    features: @data_hash_array
                  }
      data_hash.to_json
    end
  end
end
