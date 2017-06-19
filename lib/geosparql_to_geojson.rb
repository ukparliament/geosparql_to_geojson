require 'geosparql_to_geojson/version'
require 'geosparql_to_geojson/converter'
require 'geosparql_to_geojson/geojson_validator.rb'

# Namespace for classes and modules that deal with converting GeoSparql to GeoJSON  
module GeosparqlToGeojson
  def self.convert_to_geojson(geosparql_data)
    geojson = GeosparqlToGeojson::Converter.new(geosparql_data).convert

    geojson_validation = GeosparqlToGeojson::GeojsonValidator.new(geojson)

    # TODO: refactor
    if geojson_validation.valid?
      geojson
    else
      geojson_validation.errors
    end
  end
end