# frozen_string_literal: true

module TNM
  module Parser
    module Shapefile
      # The main file header is fixed at 100 bytes in length and contains 17
      # fields; nine 4-byte (32-bit signed integer or int32) integer fields
      # followed by eight 8-byte (double) signed floating point fields
      class Header
        INSPECT_FORMAT = <<~EOS
          file_code: %d
          file_length: %d
          version: %d
          shape_type: %s
          mbr: %s
          z_range: %s
          m_range: %s
        EOS
        LENGTH = 100
        Rectangle = Struct.new(:x_min, :y_min, :x_max, :y_max)

        SHAPE_TYPES = {
          0 => :null,
          1 => :point,
          3 => :poly_line,
          5 => :polygon,
          8 => :multi_point,
          11 => :point_z,
          13 => :poly_line_z,
          15 => :polygon_z,
          18 => :multi_point_z,
          21 => :point_m,
          23 => :poly_line_m,
          25 => :polygon_m,
          28 => :multi_point_m,
          31 => :multi_patch
        }.freeze

        def initialize(data)
          unless binary_string?(data)
            raise "Expected a binary string, got #{data&.encoding}"
          end
          unless data.length == LENGTH
            raise "Expected #{LENGTH} bytes, got #{data.length}"
          end
          parse(data)
        end

        def inspect
          format(
            INSPECT_FORMAT,
            @file_code,
            @file_length,
            @version,
            @shape_type,
            @mbr,
            @z_range,
            @m_range
          )
        end

        private

        # `encoding` actually returns `ASCII_8BIT` which is equal to `BINARY`.
        # https://stackoverflow.com/questions/48255737/difference-between-encodingbinary-and-encodingascii-8bit
        def binary_string?(data)
          data.instance_of?(::String) && data.encoding == ::Encoding::BINARY
        end

        # data is a 100 byte binary string
        def parse(data)
          values = unpack_binary_string(data)
          @file_code = values[0] # always hex value 0x0000270a
          @file_length = values[6] # in 16-bit words, including the header
          @version = values[7]
          @shape_type = SHAPE_TYPES.fetch(values[8])

          # Minimum bounding rectangle (MBR) of all shapes contained within the
          # dataset; four doubles in the following order: min X, min Y, max X,
          # max Y
          @mbr = Rectangle.new(*values[9..12])

          # Range of Z; two doubles in the following order: min Z, max Z
          @z_range = (values[13]..values[14])

          # Range of M; two doubles in the following order: min M, max M
          @m_range = (values[15]..values[16])
        end

        # l>   32-bit signed int, big-endian
        # l<   32-bit signed int, little-endian
        # E    signed double, little-endian
        def unpack_binary_string(data)
          data.unpack('l>7l<2E8')
        end
      end
    end
  end
end
