require 'spec_helper'

module UCBLIT
  module TIND
    module MARC
      describe XMLReader do
        it 'reads MARC records' do
          reader = XMLReader.new('spec/data/records-api-search.xml')
          records = reader.to_a
          expect(records.size).to eq(5)
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
            expected = 'DnF1ZXJ5VGhlbkZldGNoBQAAAAABw6adFmN0YjJMb0tKUTQtV1VfVzI2Qm8yY1EAAAAAGFyBJBZJT2M0QjVUaVFvV01MZS1VeU44cC13AAAAAAG2ThEWNlR5UGc4SEFSVlM4eGQwMF9BUUxHUQAAAAABu3E3FklOQ0hlX1JRU2xtV1RpY0xva3g2SWcAAAAAChqraRZjdjc0YXN0ZlNUMkd2TXFVX3psSWR3'
            reader = XMLReader.new('spec/data/records-api-search-p1.xml')
            reader.take_while { true } # make sure we've parsed something
            expect(reader.search_id).to eq(expected)
          end
        end
      end
    end
  end
end
