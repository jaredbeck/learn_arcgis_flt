#!/usr/bin/env ruby

# frozen_string_literal: true

require 'chunky_png'

$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))
require 'tnm/parser/gridfloat'
require 'tnm/range_tracker'

# The National Map (TNM)
module TNM
  # Main class, parses ARGV and mediates between Input and Output.
  class CLI
    USAGE = 'png.rb input_file output_file'

    def initialize(input_file, output_file)
      @input = Parser::Gridfloat.new(input_file)
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
end

if ARGV.length == 2
  TNM::CLI.new(*ARGV).run
else
  abort TNM::CLI::USAGE
end
