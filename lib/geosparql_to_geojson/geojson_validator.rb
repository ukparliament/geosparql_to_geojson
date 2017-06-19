require 'json-schema'

module GeosparqlToGeojson
  class GeojsonValidator
    def initialize(geojson)
      @geojson = geojson
      @schema  = JSON.parse(File.read(File.expand_path('../schema/geojson.json', __FILE__)))
    end

    def errors
      JSON::Validator.fully_validate(@schema, @geojson)
    end

    def valid?
      errors.empty?
    end
  end
end
