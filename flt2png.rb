# frozen_string_literal: true

require 'chunky_png'

module LearnArcGISFLT
  # Main class, parses ARGV and mediates between Input and Output.
  class CLI
    def initialize(input_file, output_file)
      @input = Input.new(input_file)
      @output = Output.new(3612, 3612, output_file)
    end

    def run
      range_tracker = RangeTracker.new
      print 'Reading FLT input, building PNG:    '
      until @input.eof?
        @input.read_floats.each do |float|
          range_tracker.record(float)
          @output.write(float)
        end
      end
      print "\n"
      range_tracker.print
      @output.save
    ensure
      @input.close
    end
  end

  # Tracks minimum and maximum values seen, without storing all values.
  class RangeTracker
    def record(value)
      if @min.nil? || value < @min
        @min = value
      end
      if @max.nil? || value > @max
        @max = value
      end
    end

    def print
      puts format('Elevation range: %.0f .. %.0f', @min, @max)
    end
  end

  # Wrapper around PNG object. Determines color of each pixel.
  class Output
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

  # Provides, via `#next`, a series of points in a rectangle.
  class RectangleCursor
    def initialize(width, height)
      @width = width
      @height = height
    end

    def next
      increment
      [@x, @y]
    end

    private

    def increment
      if @x.nil?
        @x = 0
        @y = 0
      elsif @x < @width - 1
        @x += 1
      else
        print format("\b\b\b%2d%%", percent_complete(@y))
        @x = 0
        @y += 1
      end
    end

    def percent_complete(y)
      (y.to_f / @height.to_f * 100.0).to_i
    end
  end

  # In a floating-point binary file, the values are written as binary 32-bit
  # signed floating-point numbers. The first record of the file corresponds to
  # the first row of the raster. Going from left to right, the first 32 bits are
  # the first cell, the next 32 bits are the second cell, and so on, to the end
  # of the record (row). This is repeated for the second record (the second row
  # of the raster) and all the way until the last record (the bottom row of the
  # raster).
  # http://desktop.arcgis.com/en/arcmap/10.3/tools/conversion-toolbox/float-to-raster.htm
  class Input
    # How many bytes to read at a time. Value must be multiple of 4, because
    # we are reading 32-bit floats. Optimal value is unknown. 512 seems to be
    # the APFS block size?
    READ_BYTES = 512

    def initialize(path)
      @file = File.open(path)
    end

    def close
      @file.close
    end

    def eof?
      @file.eof?
    end

    # Returns an array of floats.
    def read_floats
      @file.read(READ_BYTES).unpack('e*')
    end
  end
end

LearnArcGISFLT::CLI.new(*ARGV).run
