require 'spec_helper'
require 'roo'

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
            expected_csv = expected_table.to_csv
            actual_csv = Export.export_csv(collection)

            # File.open('tmp/actual.csv', 'wb') { |f| f.write(actual_csv) }
            # File.open('tmp/expected.csv', 'wb') { |f| f.write(expected_csv) }
            expect(actual_csv).to eq(expected_csv)
          end

          it 'exports to an IO' do
            expected_csv = expected_table.to_csv

            actual_csv = StringIO.new.tap do |out|
              Export.export_csv(collection, out)
            end.string

            # File.open('tmp/actual.csv', 'wb') { |f| f.write(actual_csv) }
            # File.open('tmp/expected.csv', 'wb') { |f| f.write(expected_csv) }
            expect(actual_csv).to eq(expected_csv)
          end
        end

        describe :export_libreoffice do
          it 'returns a string by default' do
            result = Export.export_libreoffice(collection)

            Dir.mktmpdir(basename) do |dir|
              output_path = File.join(dir, "#{basename}.ods")
              File.write(output_path, result)

              # TODO: share verification code
              ss = Roo::Spreadsheet.open(output_path)

              # NOTE: spreadsheets are 1-indexed, but row 1 is header

              aggregate_failures 'headers' do
                expected_table.headers.each_with_index do |h, col|
                  ss_col = 1 + col
                  actual_header = ss.cell(1, ss_col)
                  expect(actual_header).to eq(h), "Expected header #{h.inspect} for column #{ss_col}, got #{actual_header.inspect}"
                end
              end

              aggregate_failures 'values' do
                (0..expected_table.row_count).each do |row|
                  ss_row = 2 + row # row 1 is header
                  (0..expected_table.column_count).each do |col|
                    ss_col = 1 + col
                    expected_value = expected_table.value_at(row, col)
                    actual_value = ss.cell(ss_row, ss_col)
                    expect(actual_value).to eq(expected_value), "(#{ss_row}, #{ss_col}): expected #{expected_value.inspect}, got #{actual_value.inspect}"
                  end
                end
              end

              ss.close
            end
          end

          it 'exports to an IO' do
            Dir.mktmpdir(basename) do |dir|
              output_path = File.join(dir, "#{basename}.ods")
              File.open(output_path, 'wb') do |f|
                # records = API::Search.new(collection: collection).each_result(freeze: true).to_a
                Export.export_libreoffice(collection, f)
              end

              # TODO: share verification code
              ss = Roo::Spreadsheet.open(output_path)

              # NOTE: spreadsheets are 1-indexed, but row 1 is header

              aggregate_failures 'headers' do
                expected_table.headers.each_with_index do |h, col|
                  ss_col = 1 + col
                  actual_header = ss.cell(1, ss_col)
                  expect(actual_header).to eq(h), "Expected header #{h.inspect} for column #{ss_col}, got #{actual_header.inspect}"
                end
              end

              aggregate_failures 'values' do
                (0..expected_table.row_count).each do |row|
                  ss_row = 2 + row # row 1 is header
                  (0..expected_table.column_count).each do |col|
                    ss_col = 1 + col
                    expected_value = expected_table.value_at(row, col)
                    actual_value = ss.cell(ss_row, ss_col)
                    expect(actual_value).to eq(expected_value), "(#{ss_row}, #{ss_col}): expected #{expected_value.inspect}, got #{actual_value.inspect}"
                  end
                end
              end

              ss.close
            end
          end

          it 'exports to a file' do
            Dir.mktmpdir(basename) do |dir|
              output_path = File.join(dir, "#{basename}.ods")
              Export.export_libreoffice(collection, output_path)

              # TODO: share verification code
              ss = Roo::Spreadsheet.open(output_path)

              # NOTE: spreadsheets are 1-indexed, but row 1 is header

              aggregate_failures 'headers' do
                expected_table.headers.each_with_index do |h, col|
                  ss_col = 1 + col
                  actual_header = ss.cell(1, ss_col)
                  expect(actual_header).to eq(h), "Expected header #{h.inspect} for column #{ss_col}, got #{actual_header.inspect}"
                end
              end

              aggregate_failures 'values' do
                (0..expected_table.row_count).each do |row|
                  ss_row = 2 + row # row 1 is header
                  (0..expected_table.column_count).each do |col|
                    ss_col = 1 + col
                    expected_value = expected_table.value_at(row, col)
                    actual_value = ss.cell(ss_row, ss_col)
                    expect(actual_value).to eq(expected_value), "(#{ss_row}, #{ss_col}): expected #{expected_value.inspect}, got #{actual_value.inspect}"
                  end
                end
              end

              ss.close
            end
          end
        end

        describe :export do
          describe 'CSV formats' do
            attr_reader :expected_csv

            before(:each) do
              @expected_csv = expected_table.to_csv
            end

            it 'defaults to CSV' do
              actual_csv = Export.export(collection)
              expect(actual_csv).to eq(expected_csv)
            end

            [Export::ExportFormat::CSV, :csv, 'CSV'].each do |fmt|
              it "accepts #{fmt.inspect} as a format parameter" do
                actual_csv = Export.export(collection, fmt)
                # File.open("tmp/actual-#{i}.csv", 'wb') { |f| f.write(actual_csv) }
                # File.open("tmp/expected-#{i}.csv", 'wb') { |f| f.write(expected_csv) }
                expect(actual_csv).to eq(expected_csv), "Wrong CSV for #{fmt.inspect}"
              end
            end
          end

          describe 'ODS formats' do
            [Export::ExportFormat::ODS, :ods, 'ODS'].each_with_index do |fmt, i|
              it "accepts #{fmt.inspect} as a format parameter" do
                Dir.mktmpdir(basename) do |dir|
                  output_path = File.join(dir, "#{basename}-#{i}.ods")
                  Export.export(collection, fmt, output_path)

                  # TODO: share verification code
                  ss = Roo::Spreadsheet.open(output_path)

                  # NOTE: spreadsheets are 1-indexed, but row 1 is header

                  aggregate_failures 'headers' do
                    expected_table.headers.each_with_index do |h, col|
                      ss_col = 1 + col
                      actual_header = ss.cell(1, ss_col)
                      expect(actual_header).to eq(h), "Expected header #{h.inspect} for column #{ss_col}, got #{actual_header.inspect}"
                    end
                  end

                  aggregate_failures 'values' do
                    (0..expected_table.row_count).each do |row|
                      ss_row = 2 + row # row 1 is header
                      (0..expected_table.column_count).each do |col|
                        ss_col = 1 + col
                        expected_value = expected_table.value_at(row, col)
                        actual_value = ss.cell(ss_row, ss_col)
                        expect(actual_value).to eq(expected_value), "(#{ss_row}, #{ss_col}): expected #{expected_value.inspect}, got #{actual_value.inspect}"
                      end
                    end
                  end

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
