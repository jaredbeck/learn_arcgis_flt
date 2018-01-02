#!/usr/bin/env ruby

# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))
require 'tnm/parser/gridfloat'
require 'tnm/png'
require 'tnm/range_tracker'

# The National Map (TNM)
module TNM
  # Main class, parses ARGV and mediates between Input and Output.
  class CLI
    USAGE = 'png.rb input_file output_file'

    def initialize(input_file, output_file)
      @input = Parser::Gridfloat.new(input_file)
      @output = PNG.new(3612, 3612, output_file)
    end

    def run
      range_tracker = RangeTracker.new
      print 'Reading FLT input, building PNG ..'
      until @input.eof?
        @input.read_floats.each do |float|
          range_tracker.record(float)
          @output.write(float)
        end
      end
      print "\n"
      range_tracker.print
      puts 'Writing PNG ..'
      @output.save
    ensure
      @input.close
    end
  end
end

if ARGV.length == 2
  TNM::CLI.new(*ARGV).run
else
  abort TNM::CLI::USAGE
end
