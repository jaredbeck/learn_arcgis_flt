#!/usr/bin/env ruby

# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))
require 'tnm/parser/gridfloat'
require 'tnm/parser/shapefile/shp'
require 'tnm/png'
require 'tnm/range_tracker'

# The National Map (TNM)
module TNM
  # Main class, parses ARGV and mediates between Input and Output.
  class CLI
    USAGE = 'png.rb ned_file nhd_file output_file'

    # - ned_file - path to National Elevation Dataset (NED) Gridfloat file
    # - nhd_file - path to National Hydrography Dataset (NHD) Shapefile
    # - output_file - path to output PNG
    def initialize(ned_file, nhd_file, output_file)
      @ned = Parser::Gridfloat.new(ned_file)
      @nhd_file = nhd_file
      @output = PNG.new(3612, 3612, output_file)
    end

    def run
      hydrography
      elevation
      write_png
    end

    private

    def elevation
      range_tracker = RangeTracker.new
      print 'Reading FLT input, building PNG ..'
      until @ned.eof?
        @ned.read_floats.each do |float|
          range_tracker.record(float)
          @output.write(float)
        end
      end
      print "\n"
      range_tracker.print
    ensure
      @ned.close
    end

    def hydrography
      nhd_stream = File.open(@nhd_file)
      nhd = Parser::Shapefile::SHP.new(nhd_stream)
      puts nhd.header.inspect
    ensure
      nhd_stream.close
    end

    def write_png
      puts 'Writing PNG ..'
      @output.save
    end
  end
end

if ARGV.length == 3
  TNM::CLI.new(*ARGV).run
else
  abort TNM::CLI::USAGE
end
