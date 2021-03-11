require 'rspec'
require 'ucblit/util/strings'

RSpec::Matchers.define :match_table do |expected_table|
  match { |actual| diff(expected_table, actual).empty? }

  failure_message do |actual|
    diff = diff(expected_table, actual)

    msg_elements = ['output differs from table:']
    diff.each do |(row, col), (v_expected, v_actual)|
      msg = format_diff_msg(row, col, v_expected, v_actual)
      msg_elements << msg
    end
    msg_elements.join("\n\t")
  end

  def diff(expected_table, ss_or_csv_str)
    return diff_spreadsheet(expected_table, ss_or_csv_str) if ss_or_csv_str.respond_to?(:cell)

    diff_csv(expected_table, ss_or_csv_str)
  end

  def diff_spreadsheet(expected_table, spreadsheet)
    {}.tap do |diffs|
      # NOTE: spreadsheet rows are 1-indexed, but row 1 is header
      expected_table.headers.each_with_index do |expected_header, col|
        cell_index = [1, 1 + col]
        next if expected_header == (actual_header = spreadsheet.cell(*cell_index))

        diffs[cell_index] = [expected_header, actual_header]
      end

      (0..expected_table.row_count).each do |row|
        ss_row = 2 + row # row 1 is header
        (0..expected_table.column_count).each do |col|
          cell_index = [ss_row, 1 + col]
          expected_value = expected_table.value_at(row, col)
          actual_value = spreadsheet.cell(*cell_index)
          next if expected_value == actual_value

          diffs[cell_index] = [expected_value, actual_value]
        end
      end
    end
  end

  def diff_csv(expected_table, csv_string)
    # NOTE: CSV.parse() returns zero-indexed row array
    csv = CSV.parse(csv_string, headers: false)
    {}.tap do |diffs|
      header_row = csv[0]
      expected_table.headers.each_with_index do |expected_header, col|
        next if expected_header == (actual_header = header_row[col])

        diffs[[0, col]] = [expected_header, actual_header]
      end

      (0...expected_table.row_count).each do |row|
        csv_row = 1 + row # row 1 is header
        row_values = csv[csv_row] || []
        (0...expected_table.column_count).each do |col|
          expected_value = expected_table.value_at(row, col)
          actual_value = row_values[col]
          next if expected_value == actual_value

          diffs[[csv_row, col]] = [expected_value, actual_value]
        end
      end
    end
  end

  def matching_spreadsheet?(expected_table, spreadsheet)
    aggregate_failures 'headers' do
      expected_table.headers.each_with_index do |h, col|
        ss_col = 1 + col
        actual_header = spreadsheet.cell(1, ss_col)
        expect(actual_header).to eq(h), "Expected header #{h.inspect} for column #{ss_col}, got #{actual_header.inspect}"
      end
    end

    aggregate_failures 'values' do
      (0..expected_table.row_count).each do |row|
        ss_row = 2 + row # row 1 is header
        (0..expected_table.column_count).each do |col|
          ss_col = 1 + col
          expected_value = expected_table.value_at(row, col)
          actual_value = spreadsheet.cell(ss_row, ss_col)
          expect(actual_value).to eq(expected_value), "(#{ss_row}, #{ss_col}): expected #{expected_value.inspect}, got #{actual_value.inspect}"
        end
      end
    end
  end

  # TODO: make this work better
  def format_diff_msg(row, col, v_expected, v_actual)
    if (diff_index = UCBLIT::Util::Strings.diff_index(v_expected, v_actual))
      <<~MSG
        (#{row}, #{col}):
                expected: #{v_expected.inspect}#{' '}
                     got: #{v_actual.inspect}
                          #{' ' * diff_index}^
      MSG
    else
      <<~MSG
        (#{row}, #{col}):#{' '}
                expected: #{v_expected.inspect}#{' '}
                     got: #{v_actual.inspect}
      MSG
    end
  end
end
