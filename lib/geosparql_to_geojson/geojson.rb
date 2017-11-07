# frozen_string_literal: true

# Namespace for classes and modules that deal with converting GeoSparql to GeoJSON
# @since 0.1.0
module GeosparqlToGeojson
  # GeoJSON object
  #
  # @since 0.1.0
  class GeoJson
    attr_reader :geojson

    def initialize(geojson_string)
      @geojson = geojson_string
    end

    # Creates new instance of GeosparqlToGeojson::GeojsonValidator
    #
    # @return [GeosparqlToGeojson::GeojsonValidator]
    def validate
      GeosparqlToGeojson::GeojsonValidator.new(geojson)
    end
  end
end
