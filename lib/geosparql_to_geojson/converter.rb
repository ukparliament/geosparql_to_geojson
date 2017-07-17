require 'json'

module GeosparqlToGeojson
  # Class to convert GeoSparql to GeoJSON data.
  #
  # @since 0.1.0
  class Converter
    # Constant containing hash of GeoSparql types and the correctly formatted version.
    GEOSPARQL_TYPES = {
      polygon:            :Polygon,
      point:              :Point,
      multipoint:         :MultiPoint,
      linestring:         :LineString,
      multipolygon:       :MultiPolygon,
      geometrycollection: :GeometryCollection,
      multiline:          :Multiline
    }.freeze

    # Constant regex containing every GeoSparql data type that finds the type and the type's values.
    GEOMETRY_REGEX = /(#{GEOSPARQL_TYPES.values.join('|')})\(+(.*?)\)+/i

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

    private

    # Creates a hash of each GeoSparql type present and it's values.
    def collect_geosparql_data
      @data_store = {}

      if @geosparql_values.is_a?(Array)
        @geosparql_values.each do |value|
          scanned_data = value.scan(GEOMETRY_REGEX)
          populate_data_hash(scanned_data)
        end
      else
        scanned_data = @geosparql_values.scan(GEOMETRY_REGEX)
        populate_data_hash(scanned_data)
      end

      format_geosparql_data
    end

    # Sets the hash key to the GeoSparql type if it isn't already set and adds the GeoSparql values
    def populate_data_hash(scanned_geosparql_data)
      scanned_geosparql_data.each do |data|
        key = convert_key_to_correct_format(data[0])
        @data_store[key] = [] unless @data_store[key]
        @data_store[key] << data[1]
      end
    end

    # Converts the key that's captured by the regex into the correct format
    def convert_key_to_correct_format(key)
      key = key.downcase
      GEOSPARQL_TYPES[key.to_sym]
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
      values = values.first if values.is_a?(Array)
      values = values.split(/[\s]|[,]/).map!(&:to_f)
      values.reverse! if @reverse

      values = values.each_slice(2).to_a if key != :Point
      values = [values] if key != :Point && key != :LineString
      values
    end

    # Created a hash from the GeoSparql values in the GeoJSON 'Feature' format.
    def generate_hash_from_values
      @data_hash_array = []
      @data_store.keys.each do |key|
        @data_store[key.to_sym].each do |data|
          @data_hash_array << generate_feature_hash(type: key.to_s, coordinates: data)
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
      {
        type: 'FeatureCollection',
        features: @data_hash_array
      }.to_json
    end
  end
end
