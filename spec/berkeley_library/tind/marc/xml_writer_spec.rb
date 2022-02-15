require 'spec_helper'
require 'equivalent-xml'

module BerkeleyLibrary
  module TIND
    module MARC
      describe XMLWriter do
        let(:input_path) { 'spec/data/new-records.xml' }
        attr_reader :record

        before(:each) do
          reader = XMLReader.new(input_path)
          @record = reader.first
        end

        describe :open do

          it 'writes a MARC record to a file as XML' do
            Dir.mktmpdir(File.basename(__FILE__, '.rb')) do |dir|
              output_path = File.join(dir, 'marc.xml')
              XMLWriter.open(output_path) { |w| w.write(record) }

              expected = File.open(input_path) { |f| Nokogiri::XML(f) }
              actual = File.open(output_path) { |f| Nokogiri::XML(f) }

              aggregate_failures do
                EquivalentXml.equivalent?(expected, actual) do |n1, n2, result|
                  expect(n2.to_s).to eq(n1.to_s) unless result
                end
              end
            end
          end

          it 'writes a MARC record to a StringIO' do
            out = StringIO.new
            XMLWriter.open(out) { |w| w.write(record) }
            expected = File.open(input_path) { |f| Nokogiri::XML(f) }
            actual = Nokogiri::XML(out.string)
            aggregate_failures do
              EquivalentXml.equivalent?(expected, actual) do |n1, n2, result|
                expect(n2.to_s).to eq(n1.to_s) unless result
              end
            end
          end

          it 'accepts Nokogiri options' do
            Dir.mktmpdir(File.basename(__FILE__, '.rb')) do |dir|
              expected_path = File.join(dir, 'expected.xml')
              XMLWriter.open(expected_path) { |w| w.write(record) }

              actual_path = File.join(dir, 'actual.xml')
              XMLWriter.open(actual_path, indent_text: "\t") { |w| w.write(record) }

              expected = File.read(expected_path).gsub(%r{ (?= *<)(?!/)}, "\t")
              actual = File.read(actual_path)
              expect(actual).to eq(expected)
            end
          end

          it 'accepts an explicit UTF-8 argument' do
            Dir.mktmpdir(File.basename(__FILE__, '.rb')) do |dir|
              output_path = File.join(dir, 'marc.xml')
              XMLWriter.open(output_path, encoding: 'UTF-8') { |w| w.write(record) }

              expected = File.open(input_path) { |f| Nokogiri::XML(f) }
              actual = File.open(output_path) { |f| Nokogiri::XML(f) }

              aggregate_failures do
                EquivalentXml.equivalent?(expected, actual) do |n1, n2, result|
                  expect(n2.to_s).to eq(n1.to_s) unless result
                end
              end
            end
          end

          it 'only writes UTF-8' do
            Dir.mktmpdir(File.basename(__FILE__, '.rb')) do |dir|
              output_path = File.join(dir, 'marc.xml')
              expect { XMLWriter.open(output_path, encoding: 'UTF-16') }.to raise_error(ArgumentError)
              expect(File.exist?(output_path)).to eq(false)
            end
          end

          it 'rejects an invalid file path' do
            bad_directory = Dir.mktmpdir(File.basename(__FILE__, '.rb')) { |dir| dir }
            expect(File.directory?(bad_directory)).to eq(false)
            output_path = File.join(bad_directory, 'marc.xml')
            expect { XMLWriter.open(output_path) }.to raise_error(ArgumentError)
          end

          it 'rejects a non-IO, non-String argument' do
            invalid_target = Object.new
            expect { XMLWriter.open(invalid_target) }.to raise_error(ArgumentError)
          end
        end

        describe :close do
          it 'closes without writing the closing tag if nothing has been written' do
            Dir.mktmpdir(File.basename(__FILE__, '.rb')) do |dir|
              output_path = File.join(dir, 'marc.xml')
              w = XMLWriter.new(output_path)
              w.close

              stat = File.stat(output_path)
              expect(stat.size).to eq(0)
            end
          end

          it 'writes the closing tag if the opening tag has been written' do
            Dir.mktmpdir(File.basename(__FILE__, '.rb')) do |dir|
              output_path = File.join(dir, 'marc.xml')
              XMLWriter.open(output_path)
              expect(File.exist?(output_path)).to eq(true)

              doc = File.open(output_path) { |f| Nokogiri::XML(f) }
              expect(doc.root.name).to eq('collection')
            end
          end
        end

        describe :write do
          it 'raises an IOError if the writer has already been closed' do
            Dir.mktmpdir(File.basename(__FILE__, '.rb')) do |dir|
              output_path = File.join(dir, 'marc.xml')
              w = XMLWriter.new(output_path)
              w.close

              expect { w.write(record) }.to raise_error(IOError)

              stat = File.stat(output_path)
              expect(stat.size).to eq(0)
            end
          end
        end
      end
    end
  end
end
