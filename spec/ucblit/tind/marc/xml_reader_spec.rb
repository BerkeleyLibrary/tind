require 'spec_helper'

module UCBLIT
  module TIND
    module MARC
      describe XMLReader do
        let(:basename) { File.basename(__FILE__, '.rb') }

        it 'reads MARC records' do
          reader = XMLReader.new('spec/data/records-api-search.xml')
          records = reader.to_a
          expect(records.size).to eq(5)

          record0 = records[0]
          expect(record0).to be_a(::MARC::Record)
          expect(record0['024']['a']).to eq('BANC PIC 1982.078:15--ALB')
        end

        describe :new do
          it 'accepts a string path' do
            path = 'spec/data/records-api-search.xml'
            reader = XMLReader.new(path)
            records = reader.to_a
            expect(records.size).to eq(5)
          end

          it 'accepts a Pathname' do
            path = Pathname.new('spec/data/records-api-search.xml')
            reader = XMLReader.new(path)
            records = reader.to_a
            expect(records.size).to eq(5)
          end

          it 'accepts an XML string' do
            xml = File.read('spec/data/records-api-search.xml')
            reader = XMLReader.new(xml)
            records = reader.to_a
            expect(records.size).to eq(5)
          end

          it 'accepts an IO' do
            File.open('spec/data/records-api-search.xml', 'rb') do |f|
              reader = XMLReader.new(f)
              records = reader.to_a
              expect(records.size).to eq(5)
            end
          end

          it 'raises ArgumentError if passed a nonexistent file' do
            output_path = Dir.mktmpdir(basename) { |dir| File.join(dir, "#{basename}-missing.xml") }
            expect(File.exist?(output_path)).to be_falsey # just to be sure
            expect { XMLReader.new(output_path) }.to raise_error(ArgumentError)
          end

          it 'raises ArgumentError if passed a non-XML string' do
            non_xml = File.read('spec/data/collections.json')
            expect { XMLReader.new(non_xml) }.to raise_error(ArgumentError)
          end

          it 'raises ArgumentError if passed something random' do
            non_xml = Object.new
            # noinspection RubyYardParamTypeMatch
            expect { XMLReader.new(non_xml) }.to raise_error(ArgumentError)
          end
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
            expected = 'DnF1ZXJ5VGhlbkZldG'
            reader = XMLReader.new('spec/data/records-api-search-p1.xml')
            reader.take_while { true } # make sure we've parsed something
            expect(reader.search_id).to eq(expected)
          end
        end

      end
    end
  end
end
