require 'json'

module GeosparqlToGeojson
  # Class to convert GeoSparql to GeoJSON data.
  #
  # @since 0.1.0
  class Converter
    # Constant contains every GeoSparql data type.
    GEOMETRY_TYPES = %w[Point Multipoint LineString Multiline Polygon MultiPolygon GeometryCollection].freeze

    # Creates a new instance of GeosparqlToGeojson::Converter
    #
    # @param [String] geosparql_data the GeoSparql data to be converted into GeoJSON.
    def initialize(geosparql_values, geosparql_properties, reverse)
      @geosparql_values     = geosparql_values
      @geosparql_properties = geosparql_properties
      @reverse              = reverse
    end

    # Method calls GeosparqlToGeojson::Converter#collect_geosparql_data to start converting data.
    #
    # @example Converting GeoSparql string into GeoJSON
    #   GeosparqlToGeojson::Converter.new('Point(1.23 9.87)').convert
    #   #=> '{
    #          "type": "FeatureCollection",
    #          "features": [
    #            {
    #              "type": "Feature",
    #              "geometry": {
    #                "type": "Point",
    #                "coordinates": [
    #                  1.23,
    #                  9.87
    #                ]
    #              },
    #              "properties": {}
    #        }'
    def convert
      GeosparqlToGeojson::GeoJson.new(collect_geosparql_data)
    end

    # Creates a hash of each GeoSparql type present and it's values.
    def collect_geosparql_data
      @data_store = {}
      GEOMETRY_TYPES.each do |geometry_type|
        geosparql_data_match = @geosparql_values.scan(/#{geometry_type}\(+(.*?)\)+/i)
        @data_store[geometry_type.to_sym] = geosparql_data_match unless geosparql_data_match.empty?
      end

      format_geosparql_data
    end

    # Splits values into arrays and converts them into floats.
    def format_geosparql_data
      @data_store.keys.each do |key|
        @data_store[key.to_sym].map! do |values|
          format_data(values, key)
        end
      end

      generate_hash_from_values
    end

    # Formats GeoSparql data.
    # Will reverse the values if @reverse is set to true.
    #
    # @param [String] values the GeoSparql data to be converted into GeoJSON.
    # @param [Symbol] key the type of GeoSparql data
    #
    # @return [Array]
    def format_data(values, key)
      values = @reverse ? values[0].split(/[\s]|[,]/).map!(&:to_f).reverse : values[0].split(/[\s]|[,]/).map!(&:to_f)

      values = values.each_slice(2).to_a if key != :Point
      values = [values] if key != :Point && key != :LineString
      values
    end

    # Created a hash from the GeoSparql values in the GeoJSON 'Feature' format.
    def generate_hash_from_values
      @data_hash_array = []
      @data_store.keys.each do |key|
        @data_store[key.to_sym].each do |data|
          @data_hash_array << generate_feature_hash({ type: key.to_s, coordinates: data })
        end
      end

      generate_feature_collection
    end

    # Adds converted GeoSparql data to a GeoJSON 'feature' type.
    #
    # @return [Hash] a hash containing GeoSparql data
    def generate_feature_hash(data_hash)
      {
        type: 'Feature',
        geometry: data_hash,
        properties: @geosparql_properties
      }
    end

    # Adds GeoJSON 'feature' hash to a GeoJSON 'FeatureCollections' type.
    #
    # @return [String] a string of GeoJSON
    def generate_feature_collection
      data_hash = {
                    type: 'FeatureCollection',
                    features: @data_hash_array
                  }
      data_hash.to_json
    end
  end
end
