# frozen_string_literal: true

require 'chunky_png'
require 'tnm/rectangle_cursor'

module TNM
  # Wrapper around PNG object. Determines color of each pixel.
  class PNG
    # -282.0 # Death Valley -282 ft (-86 m)
    # +5_343 Mount Marcy 5,343 feet (1,629 m)
    # +20_310.0 # Mount McKinley summit 20,310 feet (6,190 m)
    MIN_ELEVATION = 113.345001
    MAX_ELEVATION = 649.373474
    ELEVATION_DIFFERENCE = MAX_ELEVATION - MIN_ELEVATION

    def initialize(width, height, path)
      @path = path
      @png = ChunkyPNG::Image.new(width, height, :black)
      @cursor = RectangleCursor.new(width, height)
    end

    def write(elevation)
      x, y = @cursor.next
      distance_from_black = elevation - MIN_ELEVATION
      whiteness = (distance_from_black / ELEVATION_DIFFERENCE * 255.0).to_i
      @png[x, y] = ChunkyPNG::Color.rgba(whiteness, whiteness, whiteness, 255)
    end

    def save
      @png.save(@path, interlace: false)
    end
  end
end
