# frozen_string_literal: true

require 'tnm/parser/shapefile/header'

module TNM
  module Parser
    module Shapefile
      RSpec.describe Header do
        describe '#inspect' do
          it 'returns the expected string' do
            input = [
              '0000270a00000000000000000000000000000000000000000096' \
              '013ee80300000500000070da61bf6b1d55c0f082534c3e6e434048882e' \
              'f80bdd51c0180901321906474000000000000000000000000000000000' \
              '00000000000000000000000000000000'
            ].pack('H*')
            header = described_class.new(input)
            lines = header.inspect.split("\n")
            expect(lines[0]).to eq('file_code: 9994')
            expect(lines[1]).to eq('file_length: 9830718')
            expect(lines[2]).to eq('version: 1000')
            expect(lines[3]).to eq('shape_type: polygon')
            expect(lines[4]).to include('Rectangle')
            expect(lines[5]).to eq('z_range: 0.0..0.0')
            expect(lines[6]).to eq('m_range: 0.0..0.0')
          end
        end
      end
    end
  end
end
