# frozen_string_literal: true

module TNM
  # Provides, via `#next`, a series of points in a rectangle.
  class RectangleCursor
    def initialize(width, height)
      @width = width
      @height = height
      @x = nil
      @y = nil
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
        @x = 0
        @y += 1
      end
    end
  end
end
