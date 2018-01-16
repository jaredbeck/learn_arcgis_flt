# frozen_string_literal: true

module TNM
  module Parser
    module Shapefile
      module Shapes
        # A polygon consists of one or more rings. A ring is a connected
        # sequence of four or more points that form a closed,
        # non-self-intersecting loop. A polygon may contain multiple outer
        # rings. The order of vertices or orientation for a ring indicates which
        # side of the ring is the interior of the polygon. The neighborhood to
        # the right of an observer walking along the ring in vertex order is the
        # neighborhood inside the polygon. Vertices of rings defining holes in
        # polygons are in a counterclockwise direction. Vertices for a single,
        # ringed polygon are, therefore, always in clockwise order. The rings of
        # a polygon are referred to as its parts.
        class Polygon
          def initialize(min_bounding_rect, parts, points)
            @mbr = min_bounding_rect
            @parts = parts
            @points = points
          end

          # MBR, Number of parts, Number of points, Parts, Points
          def self.parse(data)
            mbr = data.unpack('@4E4')
            num_parts = data.unpack('@36L<').first
            num_points = data.unpack('@40L<').first
            parts = data.unpack("@44L<#{num_parts}")
            points_begin_at = 44 + num_parts * 4
            points = Array.new(num_points) { |i|
              data.unpack("@#{points_begin_at + i * 16}E2")
            }
            new(mbr, parts, points)
          end

          def inspect
            str = <<~EOS
              Parts: #{@parts.length}
              Points: #{@points.length}
            EOS
            @parts.each_with_index do |e, i|
              str += "Part #{i}, offset #{e}\n"
            end
            str += "Point 0: #{@points[0]}"
            str
          end
        end
      end
    end
  end
end
