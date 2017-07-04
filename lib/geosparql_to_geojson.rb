require 'geosparql_to_geojson/version'
require 'geosparql_to_geojson/converter'
require 'geosparql_to_geojson/geojson'
require 'geosparql_to_geojson/geojson_validator.rb'

# Namespace for classes and modules that deal with converting GeoSparql to GeoJSON
# @since 0.1.0
module GeosparqlToGeojson
  # Convert GeoSparql to GeoJSON
  #
  # @param [String] geosparql_values the GeoSparql values
  # @param [Hash] geosparql_properties the properties to be added to the GeoJSON output
  # @param [true, false] reverse states whether to reverse the GeoJSON coordinates
  #
  # @return [GeosparqlToGeojson::GeoJson]
  def self.convert_to_geojson(geosparql_values: '', geosparql_properties: {}, reverse: false)
    GeosparqlToGeojson::Converter.new(geosparql_values, geosparql_properties, reverse).convert
  end
end
