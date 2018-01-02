# frozen_string_literal: true

require 'tnm/rectangle_cursor'

module TNM
  RSpec.describe RectangleCursor do
    describe '#next' do
      it 'returns the next point coordinates' do
        cursor = described_class.new(3, 2)
        result = Array.new(6) { cursor.next }
        expect(result).to eq(
          [
            [0, 0],
            [1, 0],
            [2, 0],
            [0, 1],
            [1, 1],
            [2, 1]
          ]
        )
      end
    end
  end
end
