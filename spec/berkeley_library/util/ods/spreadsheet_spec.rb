require 'spec_helper'
require 'roo'

module BerkeleyLibrary
  module Util
    module ODS
      describe Spreadsheet do
        let(:basename) { File.basename(__FILE__, '.rb') }
        let(:spreadsheet) { Spreadsheet.new }

        let(:num_cols) { 6 }
        let(:num_rows) { 12 }

        before(:each) do
          table = spreadsheet.add_table('Table 1')
          num_cols.times { |c| table.add_column("Column #{c}") }
          num_rows.times do |r|
            row = table.add_row
            num_cols.times { |c| row.set_value_at(c, (r * c).to_s) }
          end
        end

        describe :write_to do
          def check_cell_values(ss)
            aggregate_failures 'cells' do
              num_cols.times do |col|
                # NOTE: spreadsheet rows are 1-indexed, but row 1 is header
                cell_index = [1, 1 + col]
                actual = ss.cell(*cell_index)
                expected = "Column #{col}"
                expect(actual).to eq(expected), "Wrong value at #{cell_index}; expected #{expected.inspect}, was #{actual.inspect}"

                num_rows.times do |row|
                  cell_index = [2 + row, 1 + col]
                  actual = ss.cell(*cell_index)
                  expected = (row * col).to_s
                  expect(actual).to eq(expected), "Wrong value at #{cell_index}; expected #{expected.inspect}, was #{actual.inspect}"
                end
              end
            end
          end

          it 'writes to a file' do
            Dir.mktmpdir(basename) do |dir|
              output_path = File.join(dir, "#{basename}.ods")
              spreadsheet.write_to(output_path)

              ss = Roo::Spreadsheet.open(output_path, file_warning: :warning)
              check_cell_values(ss)
            end
          end

          it 'writes to a file handle' do
            Dir.mktmpdir(basename) do |dir|
              output_path = File.join(dir, "#{basename}.ods")
              File.open(output_path, 'wb') { |f| spreadsheet.write_to(f) }

              ss = Roo::Spreadsheet.open(output_path, file_warning: :warning)
              check_cell_values(ss)
            end
          end

          it 'writes to a StringIO' do
            Dir.mktmpdir(basename) do |dir|
              output_path = File.join(dir, "#{basename}.ods")
              result = StringIO.new.tap { |out| spreadsheet.write_to(out) }.string
              # File.open(output_path, 'wb') { |f| f.write(result) }
              File.binwrite(output_path, result)

              ss = Roo::Spreadsheet.open(output_path, file_warning: :warning)
              check_cell_values(ss)
            end
          end

          it 'returns a string' do
            Dir.mktmpdir(basename) do |dir|
              output_path = File.join(dir, "#{basename}.ods")
              result = spreadsheet.write_to
              # File.open(output_path, 'wb') { |f| f.write(result) }
              File.binwrite(output_path, result)

              ss = Roo::Spreadsheet.open(output_path, file_warning: :warning)
              check_cell_values(ss)
            end
          end

          it 'writes a spreadsheet as exploded XML' do
            Dir.mktmpdir(basename) do |dir|
              expected_paths_relative = %w[META-INF/manifest.xml styles.xml content.xml]
              expected_paths_absolute = expected_paths_relative.map do |path_relative|
                joined_path = File.join(dir, path_relative)
                File.absolute_path(joined_path)
              end

              files_written = spreadsheet.write_to(dir)
              expect(files_written).to match_array(expected_paths_absolute)

              expected_paths_absolute.each do |path_absolute|
                expect(File.file?(path_absolute)).to eq(true)
              end
            end
          end
        end

        describe :write_exploded do
          it 'writes a spreadsheet as exploded XML' do
            Dir.mktmpdir(basename) do |dir|
              expected_paths_relative = %w[META-INF/manifest.xml styles.xml content.xml]
              expected_paths_absolute = expected_paths_relative.map do |path_relative|
                joined_path = File.join(dir, path_relative)
                File.absolute_path(joined_path)
              end

              files_written = spreadsheet.write_exploded_to(dir)
              expect(files_written).to match_array(expected_paths_absolute)

              expected_paths_absolute.each do |path_absolute|
                expect(File.file?(path_absolute)).to eq(true)
              end
            end
          end
        end
      end
    end
  end
end
