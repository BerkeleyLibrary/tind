require 'spec_helper'

module UCBLIT
  module TIND
    describe Exporter do
      let(:records) { MARC::XMLReader.read_frozen('spec/data/records-search.xml') }

      describe :to_csv do
        it 'outputs CSV' do
          exporter = Exporter.new(records)
          csv = exporter.to_csv
          expect(csv).to be_a(String)
          # TODO: really test this
        end
      end
    end
  end
end
