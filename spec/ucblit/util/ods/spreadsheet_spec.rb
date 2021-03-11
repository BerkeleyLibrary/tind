require 'spec_helper'
require 'roo'

module UCBLIT
  module Util
    module ODS
      describe Spreadsheet do
        let(:basename) { File.basename(__FILE__, '.rb') }
        let(:spreadsheet) { Spreadsheet.new }

        it 'writes a spreadsheet' do
          num_cols = 6
          num_rows = 12

          table = spreadsheet.add_table('Table 1')
          num_cols.times { |c| table.add_column("Column #{c}") }
          num_rows.times do |r|
            row = table.add_row
            num_cols.times { |c| row.set_value_at(c, (r * c).to_s) }
          end

          Dir.mktmpdir(basename) do |dir|
            output_path = File.join(dir, "#{basename}.ods")
            spreadsheet.write_to_file(output_path)
            # File.open(output_path, 'wb') { |f| spreadsheet.write_to_stream(f) }

            ss = Roo::Spreadsheet.open(output_path, file_warning: :warning)
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
        end
      end
    end
  end
end
