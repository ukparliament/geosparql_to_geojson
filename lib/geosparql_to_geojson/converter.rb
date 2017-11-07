# frozen_string_literal: true

require 'json'

# Namespace for classes and modules that deal with converting GeoSparql to GeoJSON
#
# @since 0.1.0
module GeosparqlToGeojson
  # Namespace for classes that convert GeoSparql to GeoJSON data.
  #
  # @since 0.2.0
  module Converter
    require 'geosparql_to_geojson/converter/base_converter'
    require 'geosparql_to_geojson/converter/polygon_converter'
  end
end
