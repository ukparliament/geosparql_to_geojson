require 'json'

module GeosparqlToGeojson
  class Converter
    def initialize(constituency)
      @constituency = constituency
      @geosparql    = constituency.area
    end

    def convert
      @center_point = generate_point_hash(@geosparql.longitude, @geosparql.latitude)
      @polygons     = generate_polygon_hash(@geosparql.polygon)
      generate_polygons_json
      generate_json
    end

    def generate_point_hash(longitude, latitude)
      { type: 'Point', coordinates: [longitude[0].to_f, latitude[0].to_f] }
    end

    def generate_polygon_hash(polygons)
      polygon_array = []
      [*polygons].each do |polygon|
        polygon_points = polygon.scan(/\(\((.*?)\)\)/).first
        polygon_points = polygon_points.first.split(',')
        polygon_points.map! { |coordinate_pairs| coordinate_pairs.split(' ').map!(&:to_f) }

        polygon_array << { type: 'Polygon', coordinates: [polygon_points] }
      end

      polygon_array
    end

    def generate_json
      data_hash = {
                    type: 'FeatureCollection',
                    features: [{
                      type: 'Feature',
                      geometry: @center_point,
                      properties: {
                        description: 'center_point'
                      }
                    }]
                  }
      @polygons.each { |polygon| data_hash[:features] << polygon }
      data_hash.to_json
    end

    def generate_polygons_json
      @polygons.map! do |polygon|
        {
          type: 'Feature',
          geometry: polygon,
          properties: {
            description: 'polygon'
          }
        }
      end
    end
  end
end
