require 'spec_helper'

module UCBLIT
  module TIND
    module MARC
      describe XMLReader do
        it 'reads MARC records' do
          reader = XMLReader.new('spec/data/records-api-search.xml')
          records = reader.to_a
          expect(records.size).to eq(5)

          record0 = records[0]
          expect(record0).to be_a(::MARC::Record)
          expect(record0['024']['a']).to eq('BANC PIC 1982.078:15--ALB')
        end

        describe :total do
          it 'parses <total/>' do
            reader = XMLReader.new('spec/data/records-api-search.xml')
            reader.take_while { true } # make sure we've parsed something
            expect(reader.total).to eq(5)
          end

          it 'parses "Search-Engine-Total-Number-Of-Results"' do
            reader = XMLReader.new('spec/data/records-manual-search.xml')
            reader.take_while { true } # make sure we've parsed something
            expect(reader.total).to eq(10)
          end
        end

        describe :search_id do
          it 'parses <search_id>' do
            expected = 'adBJG2ThENlR5UGc4SEFSVlM4eGQwF9B'
            reader = XMLReader.new('spec/data/records-api-search-p1.xml')
            reader.take_while { true } # make sure we've parsed something
            expect(reader.search_id).to eq(expected)
          end
        end
      end
    end
  end
end
