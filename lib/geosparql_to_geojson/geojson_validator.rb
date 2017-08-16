# frozen_string_literal: true

require 'json-schema'

# Namespace for classes and modules that deal with converting GeoSparql to GeoJSON
#
# @since 0.1.0
module GeosparqlToGeojson
  # Class used to validate GeoJSON
  # @since 0.1.0
  class GeojsonValidator
    # Creates a new instance of GeosparqlToGeojson::GeojsonValidator.
    #
    # @param [String] geojson the GeoJSON data to be validated
    def initialize(geojson)
      @geojson = geojson
      @schema  = JSON.parse(File.read(File.expand_path('../schema/geojson.json', __FILE__)))
    end

    # Validates GeoJSON data based on JSON and GroJSON schemas.
    #
    # @return [Array] any errors with the JSON
    def errors
      JSON::Validator.fully_validate(@schema, @geojson)
    end

    # Checks whether there are any errors returned by the validator.
    #
    # @return [true, false]
    def valid?
      errors.empty?
    end
  end
end
