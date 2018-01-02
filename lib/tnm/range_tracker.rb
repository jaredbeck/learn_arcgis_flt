# frozen_string_literal: true

module TNM
  # Tracks minimum and maximum values seen, without storing all values.
  class RangeTracker
    def initialize
      @min = nil
      @max = nil
    end

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
end
