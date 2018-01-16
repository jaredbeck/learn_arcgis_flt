# frozen_string_literal: true

require 'tnm/parser/shapefile/header'
require 'tnm/parser/shapefile/shapes/polygon'

module TNM
  module Parser
    module Shapefile
      # The main file (.shp) contains the geometry data. The binary file
      # consists of a single fixed-length header followed by one or more
      # variable-length records. Each of the variable-length records includes a
      # record-header component and a record-contents component.
      class SHP
        attr_reader :header, :records

        def initialize(stream)
          parse(stream)
        end

        private

        def parse(stream)
          @header = Header.new(stream.read(Header::LENGTH))
          @records = []
          until stream.eof?
            n, words = stream.read(8).unpack('L>2')
            record = stream.read(words * 2) # 16-bit words
            shape_type = record.unpack('L<')[0]
            puts format('Record %d: type %d words %d', n, shape_type, words)
            parse_record(record, shape_type)
          end
        end

        def parse_record(record, shape_type)
          case shape_type
          when 5
            @records << Shapes::Polygon.parse(record)
          else
            raise "Unexpected shape type: #{shape_type}"
          end
        end
      end
    end
  end
end
