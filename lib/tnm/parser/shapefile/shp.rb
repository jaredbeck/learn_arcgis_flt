# frozen_string_literal: true

require 'tnm/parser/shapefile/header'

module TNM
  module Parser
    module Shapefile
      # The main file (.shp) contains the geometry data. The binary file
      # consists of a single fixed-length header followed by one or more
      # variable-length records. Each of the variable-length records includes a
      # record-header component and a record-contents component.
      class SHP
        def initialize(stream)
          @stream = stream
        end

        def header
          Header.new(@stream.read(Header::LENGTH))
        end
      end
    end
  end
end
