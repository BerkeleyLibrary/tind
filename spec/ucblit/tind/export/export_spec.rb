require 'spec_helper'
require 'roo'

require_relative 'export_matcher'

module UCBLIT
  # noinspection RubyYardParamTypeMatch
  module TIND
    describe Export do
      let(:records) do
        (1..7)
          .map { |page| File.read("spec/data/records-api-search-p#{page}.xml") }
          .map { |p| UCBLIT::TIND::MARC::XMLReader.new(p, freeze: true).to_a }
          .flatten
      end
      let(:expected_table) { Export::Table.from_records(records, freeze: true) }
      let(:collection) { 'Bancroft Library' }
      let(:basename) { File.basename(__FILE__, '.rb') }

      describe 'export' do
        before(:each) do
          search = instance_double(UCBLIT::TIND::API::Search)
          allow(search).to receive(:each_result).with(freeze: true).and_return(records.each)
          allow(UCBLIT::TIND::API::Search).to receive(:new).with(collection: collection).and_return(search)
        end

        describe :export_csv do
          it 'returns a string by default' do
            actual_csv = Export.export_csv(collection)
            expect(actual_csv).to match_table(expected_table)
          end

          it 'exports to an IO' do
            actual_csv = StringIO.new.tap do |out|
              Export.export_csv(collection, out)
            end.string

            expect(actual_csv).to match_table(expected_table)
          end
        end

        describe :export_libreoffice do
          it 'returns a string by default' do
            result = Export.export_libreoffice(collection)

            Dir.mktmpdir(basename) do |dir|
              output_path = File.join(dir, "#{basename}.ods")
              File.write(output_path, result)

              ss = Roo::Spreadsheet.open(output_path)
              begin
                expect(ss).to match_table(expected_table)
              ensure
                ss.close
              end
            end
          end

          it 'exports to an IO' do
            Dir.mktmpdir(basename) do |dir|
              output_path = File.join(dir, "#{basename}.ods")
              File.open(output_path, 'wb') do |f|
                # records = API::Search.new(collection: collection).each_result(freeze: true).to_a
                Export.export_libreoffice(collection, f)
              end

              ss = Roo::Spreadsheet.open(output_path)
              begin
                expect(ss).to match_table(expected_table)
              ensure
                ss.close
              end
            end
          end

          it 'exports to a file' do
            Dir.mktmpdir(basename) do |dir|
              output_path = File.join(dir, "#{basename}.ods")
              Export.export_libreoffice(collection, output_path)

              ss = Roo::Spreadsheet.open(output_path)
              begin
                expect(ss).to match_table(expected_table)
              ensure
                ss.close
              end
            end
          end
        end

        describe :export do
          describe 'CSV formats' do
            it 'defaults to CSV' do
              actual_csv = Export.export(collection)
              expect(actual_csv).to match_table(expected_table)
            end

            [Export::ExportFormat::CSV, :csv, 'CSV'].each do |fmt|
              it "accepts #{fmt.inspect} as a format parameter" do
                actual_csv = Export.export(collection, fmt)
                expect(actual_csv).to match_table(expected_table)
              end
            end
          end

          describe 'ODS formats' do
            [Export::ExportFormat::ODS, :ods, 'ODS'].each_with_index do |fmt, i|
              it "accepts #{fmt.inspect} as a format parameter" do
                Dir.mktmpdir(basename) do |dir|
                  output_path = File.join(dir, "#{basename}-#{i}.ods")
                  Export.export(collection, fmt, output_path)

                  ss = Roo::Spreadsheet.open(output_path)
                  begin
                    expect(ss).to match_table(expected_table)
                  ensure
                    ss.close
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
