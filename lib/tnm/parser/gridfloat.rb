# frozen_string_literal: true

module TNM
  module Parser
    # In a floating-point binary file, the values are written as binary 32-bit
    # signed floating-point numbers. The first record of the file corresponds to
    # the first row of the raster. Going from left to right, the first 32 bits
    # are the first cell, the next 32 bits are the second cell, and so on, to
    # the end of the record (row). This is repeated for the second record (the
    # second row of the raster) and all the way until the last record (the
    # bottom row of the raster).
    # http://desktop.arcgis.com/en/arcmap/10.3/tools/conversion-toolbox/float-to-raster.htm
    class Gridfloat
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
end
