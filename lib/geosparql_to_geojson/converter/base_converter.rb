# frozen_string_literal: true

# Namespace for classes and modules that deal with converting GeoSparql to GeoJSON
#
# @since 0.1.0
module GeosparqlToGeojson
  # Namespace for classes that convert GeoSparql to GeoJSON data.
  #
  # @since 0.2.0
  module Converter
    # Class to convert GeoSparql to GeoJSON data.
    #
    # @since 0.1.0
    # @attr_reader [String] geosparql_values the GeoSPARQL values to be converted.
    # @attr_reader [Hash] geosparql_properties the GeoJSON properties to be added to the converted GeoSPARQL.
    # @attr_reader [Boolean] reverse whether the polygon data needs to be reversed.
    class BaseConverter
      attr_reader :geosparql_values, :geosparql_properties, :reverse

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
      GEOMETRY_REGEX = /(#{GEOSPARQL_TYPES.values.join('|')})?\(+(.*?)\)+/i

      # Creates a new instance of GeosparqlToGeojson::Converter::BaseConverter
      #
      # @param [String] geosparql_values the GeoSparql data to be converted into GeoJSON.
      # @param [Hash] geosparql_properties the properties to be added to the formatted GeoJSON.
      # @param [Boolean] reverse the geosparql_values data.
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
      #
      # @return [void]
      def collect_geosparql_data
        @geosparql_values_by_type = {}
        if geosparql_values.is_a?(Array)
          geosparql_values.each do |value|
            scanned_data = value.scan(GEOMETRY_REGEX)
            populate_data_hash(scanned_data)
          end
        else
          scanned_data = geosparql_values.scan(GEOMETRY_REGEX)
          populate_data_hash(scanned_data)
        end

        format_geosparql_data
      end

      # Sets the hash key to the GeoSparql type if it isn't already set and add the GeoSparql values
      #
      # @param [Array<String>] scanned_geosparql_data the GeoSPARQL data to convert.
      # @return [void]
      def populate_data_hash(scanned_geosparql_data)
        scanned_geosparql_data.each_with_index do |data, index|
          # If the data is missing a key we use the previous data points key or fallback to using 'polygon'
          data[0].nil? ? data[0] = scanned_geosparql_data[index - 1][0] : 'polygon'

          key = convert_key_to_correct_format(data[0])
          @geosparql_values_by_type[key] = [] unless @geosparql_values_by_type[key]
          @geosparql_values_by_type[key] << data[1]
        end
      end

      # Converts the key that's captured by the regex into the correct format.
      #
      # @param [String] key the GeoJSON type.
      # @return [String] the formatted GeoJSON version of the key.
      def convert_key_to_correct_format(key)
        key = key.downcase
        GEOSPARQL_TYPES[key.to_sym]
      end

      # Splits values into arrays and converts them into floats.
      # Also calls PolygonConverter to convert any polygon data that might be present.
      #
      # @return [void]
      def format_geosparql_data
        polygons = []
        @geosparql_values_by_type.each_key do |key|
          if key == :Polygon
            polygons << @geosparql_values_by_type[key]
          else
            @geosparql_values_by_type[key].map! do |values|
              format_data(values, key)
            end
          end
        end

        # Updates @geosparql_values_by_type with formatted polygon data (including holes).
        GeosparqlToGeojson::Converter::PolygonConverter.new(@geosparql_values_by_type, polygons).convert if polygons.any?

        generate_hash_from_values
      end

      # Formats GeoSparql data.
      # Will reverse the values if @reverse is set to true.
      #
      # @param [String] values the GeoSparql data to be converted into GeoJSON.
      # @param [Symbol] key the type of GeoSparql data.
      #
      # @return [Array]
      def format_data(values, key)
        values = values.first if values.is_a?(Array)
        values = values.split(/[\s,]+/).map!(&:to_f)
        values.reverse! if reverse

        values = values.each_slice(2).to_a if key != :Point
        values = [values] if key != :Point && key != :LineString
        values
      end

      # Created a hash from the GeoSparql values in the GeoJSON 'Feature' format.
      #
      # @return [void]
      def generate_hash_from_values
        @data_hash_array = []
        @geosparql_values_by_type.each_key do |key|
          @geosparql_values_by_type[key].each do |data|
            @data_hash_array << generate_feature_hash(type: key.to_s, coordinates: data)
          end
        end

        generate_feature_collection
      end

      # Adds converted GeoSparql data to a GeoJSON 'Feature' type.
      #
      # @param [Hash] data_hash the formatted GeoJSON data.
      # @return [Hash] a hash containing GeoJSON data.
      def generate_feature_hash(data_hash)
        {
          type:       'Feature',
          geometry:   data_hash,
          properties: geosparql_properties
        }
      end

      # Adds GeoJSON 'feature' hash to a GeoJSON 'FeatureCollections' type.
      #
      # @return [String] a string of formatted GeoJSON
      def generate_feature_collection
        {
          type: 'FeatureCollection',
          features: @data_hash_array
        }.to_json
      end
    end
  end
end
