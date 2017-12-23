# frozen_string_literal: true

require 'chunky_png'

module LearnArcGISFLT
  class CLI
    def initialize(input_file)
      @input = Input.new(input_file)
      @width = 3612
      @height = 3612
      @output = Output.new(3612, 3612)
    end

    def run
      min, max = nil, nil
      x, y = 0, 0
      print "Reading FLT input, building PNG:    "
      until @input.eof?
        @input.read_floats.each do |float|
          if min.nil? || float < min
            min = float
          end
          if max.nil? || float > max
            max = float
          end
          @output.write(x, y, float)
          if x < @width - 1
            x += 1
          else
            print format("\b\b\b%2d%%", percent_complete(y))
            x = 0
            y += 1
          end
        end
      end
      puts format("\nElevation range: %f .. %f", min, max)
      puts "Writing PNG output .."
      @output.save('out.png')
    ensure
      @input.close
    end

    private

    def percent_complete(y)
      (y.to_f / @height.to_f * 100.0).to_i
    end
  end

  class Output
    # -282.0 # Death Valley -282 ft (-86 m)
    # +20_310.0 # Mount McKinley summit 20,310 feet (6,190 m)
    MIN_EXPECTED = 113.345001
    MAX_EXPECTED = 649.373474
    EXPECTED_DIFFERENCE = MAX_EXPECTED - MIN_EXPECTED

    def initialize(width, height)
      @png = ChunkyPNG::Image.new(width, height, :black)
      @min_distance_from_black = nil
    end

    def write(x, y, float)
      distance_from_black = float - MIN_EXPECTED
      if @min_distance_from_black.nil? || distance_from_black < @min_distance_from_black
        @min_distance_from_black = distance_from_black
      end
      whiteness = (distance_from_black / EXPECTED_DIFFERENCE * 255.0).to_i
      @png[x, y] = ChunkyPNG::Color.rgba(whiteness, whiteness, whiteness, 255)
    end

    def save(path)
      puts "@min_distance_from_black #{@min_distance_from_black}"
      @png.save(path, interlace: false)
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
