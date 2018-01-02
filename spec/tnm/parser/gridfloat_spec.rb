# frozen_string_literal: true

require 'tnm/parser/gridfloat'

module TNM
  module Parser
    RSpec.describe Gridfloat do
      describe '#read_floats' do
        it 'returns array of floats' do
          path = File.expand_path(
            '../../../support/fixtures/test.flt',
            __FILE__
          )
          floats = described_class.new(path).read_floats
          expect(floats.length).to eq(128)
          expect(floats[0]).to be_within(0.001).of(151.8140)
          expect(floats[127]).to be_within(0.001).of(134.0890)
        end
      end
    end
  end
end
