# frozen_string_literal: true

# Namespace for classes and modules that deal with converting GeoSparql to GeoJSON
#
# @since 0.1.0
module GeosparqlToGeojson
  # Namespace for classes that convert GeoSparql to GeoJSON data.
  #
  # @since 0.2.0
  module Converter
    # Class to convert polygon data and process polygon holes.
    #
    # @since 0.2.0
    class PolygonConverter
      # Creates a new instance of GeosparqlToGeojson::Converter::PolygonConverter
      #
      # @param [Hash] geosparql_values_by_type that contains the formatted GeoSPARQL data.
      # @param [Array<String>] values the raw polygon data.
      def initialize(geosparql_values_by_type, values)
        @geosparql_values_by_type = geosparql_values_by_type
        @values     = values.flatten
        @polygons   = []
        @holes      = []
        @formatted_polygon_array = []
      end

      # Converts polygon data into the correct format and adds it to @geosparql_values_by_type.
      #
      # @return [Hash] the converted andf formatted polygon data.
      def convert
        format_data

        if @holes.any?
          match_holes_to_polygons
          format_polygons_with_holes
        end

        format_polygons_without_holes
        add_formatted_polygons_to_data_hash
      end

      private

      # Splits polygon value strings by GeoSparql syntax, strips whitespace and converts values to floats.
      #
      # @return [void]
      def format_data
        @values.map! do |values_string|
          values_string.split(/\),?\s*\(/).map! do |values|
            values = values.split(',').map(&:strip)
            values.map! { |value| value.split(/\s/).map(&:to_f) }
          end
        end

        split_into_polygons_and_holes
      end

      # Adds polygons and holes from @values to @polygons and @holes.
      #
      # @return [Array] @holes
      # @return [Array] @polygons
      def split_into_polygons_and_holes
        @values.each do |value_array|
          value_array.each do |values|
            if hole?(values)
              @holes << values
            else
              @polygons << values
            end
          end
        end
      end

      # Checks whether a polygon is a hole.
      # Uses the shoelace formula.
      #
      # @param [Array] values the polygon values.
      # @return [Boolean]
      def hole?(values)
        results = []
        count   = values.size
        values.each_with_index do |_value, index|
          current    = values[index]
          next_value = values[index + 1]

          if index < count - 1
            results << (next_value[0] - current[0]) * (next_value[1] + current[1])
          end
        end
        results.compact!
        return true if results.sum.negative?
        false
      end

      # Generates a hash containing the indexes of polygons and the holes within them.
      #
      # @return [void]
      def match_holes_to_polygons
        @matches = {}
        @polygons.each_with_index do |polygon, polygon_index|
          set_min_and_max_axis(polygon)

          @holes.each_with_index do |hole, hole_index|
            set_min_and_max_axis(hole)

            # @note This method of building a border box around the polygon and checking
            #   to see whether the min and max values of the hole fit within it
            #   will work since we already know it is a hole. Otherwise we would need a more accurate solution.
            if @x_min[1] > @x_min[0] && @x_max[1] < @x_max[0] && @y_min[1] > @y_min[0] && @y_max[1] < @y_max[0]
              @matches[polygon_index] ||= []
              @matches[polygon_index].push(hole_index)
            end

            set_min_and_max_to_first_value
          end

          reset_min_and_max_instance_variables
        end
      end

      # Sets the minumum and maximum values of a polygon's X and Y axis.
      #
      # @param [Array<Float>] values the x and y values for each point on the polygon.
      # @return [void]
      def set_min_and_max_axis(values)
        x_axis = []
        y_axis = []
        @x_min ||= []
        @x_max ||= []
        @y_min ||= []
        @y_max ||= []

        values.each do |value|
          x_axis << value[0]
          y_axis << value[1]
        end

        @x_min << x_axis.min
        @x_max << x_axis.max
        @y_min << y_axis.min
        @y_max << y_axis.max
      end

      # Sets minimum and maximum X and Y axis variables to an array containing their first value.
      #
      # @return [void]
      def set_min_and_max_to_first_value
        @x_min = [@x_min.first]
        @x_max = [@x_max.first]
        @y_min = [@y_min.first]
        @y_max = [@y_max.first]
      end

      # Sets minimum and maximum X and Y axis variables to nil.
      #
      # @return [void]
      def reset_min_and_max_instance_variables
        @x_min = nil
        @y_min = nil
        @x_max = nil
        @y_max = nil
      end

      # Adds an array of a polygon and the holes that match the polygon to @formatted_polygon_array.
      #
      # @return [void]
      def format_polygons_with_holes
        @matches.each do |key, values|
          polygon_with_holes = [@polygons[key]]

          values.each do |value|
            polygon_with_holes << @holes[value]
          end

          @formatted_polygon_array << polygon_with_holes
        end
      end

      # Adds polygons that don't have holes to @formatted_polygon_array.
      #
      # @return [void]
      def format_polygons_without_holes
        remove_polygons_with_holes if @matches

        @polygons.each { |polygon| @formatted_polygon_array << [polygon] }
      end

      # Deletes polygons that contain holes from @polygons.
      #
      # @return [void]
      def remove_polygons_with_holes
        # Need to reverse the keys so that the @polygon index doesn't change before we call #delete_at.
        @matches.keys.reverse.each { |key| @polygons.delete_at(key) }
      end

      # Adds the populated @formatted_polygon_array to @geosparql_values_by_type
      #
      # @return [Hash] @geosparql_values_by_type the 'Polygon' type with it's values. 
      def add_formatted_polygons_to_data_hash
        @geosparql_values_by_type[:Polygon] = @formatted_polygon_array
      end
    end
  end
end
