# frozen_string_literal: true

require 'tnm/range_tracker'

module TNM
  # Tracks minimum and maximum values seen, without storing all values.
  RSpec.describe RangeTracker do
    describe '#print' do
      it 'writes the recorded range to stdout' do
        tracker = described_class.new
        [1, -3.2, 7].each do |v|
          tracker.record(v)
        end
        expect { tracker.print }.to(
          output("Elevation range: -3 .. 7\n").to_stdout
        )
      end
    end
  end
end
