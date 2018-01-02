# frozen_string_literal: true

require 'fileutils'
require 'tempfile'
require 'tnm/png'

module TNM
  RSpec.describe PNG do
    describe '#save' do
      it 'writes a PNG to disk' do
        path = Tempfile.create.path
        begin
          png = described_class.new(1, 1, path)
          png.write(0.0)
          png.save

          # This expectation is brittle because PNG headers could change size in
          # the future.
          expect(File.stat(path).size).to eq(82)
        ensure
          FileUtils.rm(path)
        end
      end
    end
  end
end
