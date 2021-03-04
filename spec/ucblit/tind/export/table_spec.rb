require 'spec_helper'

module UCBLIT
  module TIND
    # noinspection RubyYardParamTypeMatch
    module Export
      describe Table do

        describe :<< do
          let(:table) { Table.new }
          let(:records) { MARC::XMLReader.read('spec/data/records-manual-search.xml', freeze: true).to_a }

          it 'adds one record' do
            table << (record = records.first)
            expect(table.marc_records).to contain_exactly(record)
          end

          it 'adds multiple records' do
            records.each { |r| table << r }
            expect(table.marc_records).to eq(records)
          end

          it 'logs the MARC record ID and data field in the event of a bad indicator' do
            tag = '245'
            ind_bad = '!'

            record = records.first
            record[tag].indicator1 = ind_bad
            expect { table << record }.to raise_error(Export::ExportException) do |e|
              expect(e.message).to include('184458')
              expect(e.message).to include(tag)
              expect(e.message).to include(ind_bad)
            end
          end
        end

        describe :headers do
          it 'aligns with the correct values' do
            records = MARC::XMLReader.read('spec/data/disjoint-records.xml', freeze: true).to_a
            table = Table.from_records(records)

            headers = table.headers
            records.each_with_index do |record, row|
              values = table.rows[row].values
              expect(values).not_to be_nil, "No values found for row #{row}"

              # uncomment this to debug:

              # puts "#{row}) #{record['245']['rows']}: #{record['500']['rows']}"
              # headers.each_with_index { |h, i| puts "\t#{h}\t#{values[i]}" }
              # puts "\n" if row + 1 < records.size

              aggregate_failures 'headers' do
                last_col = -1
                record.data_fields_by_tag.each do |tag, dff|
                  dff.each do |df|
                    ind1 = df.indicator1 == ' ' ? '_' : df.indicator1
                    ind2 = df.indicator2 == ' ' ? '_' : df.indicator2
                    df_prefix = "#{tag}#{ind1}#{ind2}"

                    expected_suffix = nil
                    df.subfields.each do |sf|
                      col = values.find_index(sf.value)
                      expect(col).to be > last_col
                      last_col = col

                      expected_prefix = "#{df_prefix}#{sf.code}"

                      header = headers[col]
                      expect(header).to start_with(expected_prefix)

                      header_suffix = header.scan(/(?<=-)[0-9]+$/).first.to_i
                      if expected_suffix
                        expect(header_suffix).to eq(expected_suffix), "#{row}, #{col}: (#{sf.value}) Expected #{expected_prefix}-#{expected_suffix}, was #{header}"
                      else
                        expected_suffix = header_suffix
                      end
                    end
                  end
                end
              end
            end
          end
        end

        describe :freeze do
          it 'prevents adding new records' do
            records = MARC::XMLReader.read('spec/data/records-manual-search.xml', freeze: true).to_a
            table = records[0...3].each_with_object(Table.new) { |r, t| t << r }
            table.freeze
            expect(table.row_count).to eq(3) # just to be sure
            original_headers = table.headers.dup

            # noinspection RubyModifiedFrozenObject
            expect { table << records.last }.to raise_error(FrozenError)
            expect(table.row_count).to eq(3)
            expect(table.headers).to eq(original_headers)
          end

          it 'freezes the MARC records array' do
            records = MARC::XMLReader.read('spec/data/records-manual-search.xml', freeze: true).to_a
            table = records.each_with_object(Table.new) { |r, t| t << r }
            table.freeze
            expect { table.marc_records << records.last }.to raise_error(FrozenError)
          end

          it 'freezes the columns' do
            records = MARC::XMLReader.read('spec/data/records-manual-search.xml', freeze: true).to_a
            table = records.each_with_object(Table.new) { |r, t| t << r }
            table.freeze

            expect { table.columns << Object.new }.to raise_error(FrozenError)
          end

          it 'freezes the rows' do
            records = MARC::XMLReader.read('spec/data/records-manual-search.xml', freeze: true).to_a
            table = records.each_with_object(Table.new) { |r, t| t << r }
            table.freeze

            expect { table.rows << Object.new }.to raise_error(FrozenError)
          end

          it 'returns self' do
            records = MARC::XMLReader.read('spec/data/records-manual-search.xml', freeze: true).to_a
            table = records.each_with_object(Table.new) { |r, t| t << r }
            expect(table.freeze).to be(table)
          end
        end

        describe :from_records do
          let(:records) { MARC::XMLReader.read('spec/data/records-manual-search.xml', freeze: true).to_a }
          it 'reads the records' do
            table = Table.from_records(records)
            expect(table.row_count).to eq(records.size)
          end

          it 'optionally freezes the table' do
            table = Table.from_records(records, freeze: true)
            expect(table.frozen?).to eq(true)
          end

          it 'parses the data fields into rows' do
            table = Table.from_records(records, freeze: true)

            aggregate_failures 'row parsing' do
              records.each_with_index do |marc_record, row|
                expected_headers = []
                expected_values = []

                marc_record.each_data_field.each do |df|
                  prefix = ColumnGroup.prefix_for(df)
                  df.subfields.each do |sf|
                    expected_headers << "#{prefix}#{sf.code}"
                    expected_values << sf.value
                  end
                end

                expected_index = 0
                table.rows[row].values.each_with_index do |actual_value, index|
                  next unless actual_value

                  expected_header = expected_headers[expected_index]
                  actual_header = table.headers[index]
                  expect(actual_header).to start_with(expected_header)

                  expected_value = expected_values[expected_index]
                  expect(actual_value).to eq(expected_value)

                  expected_index += 1
                end
              end
            end
          end

          describe :exportable_only do
            it 'filters out non-exportable values' do
              excluded_prefixes = (Filter::DO_NOT_EXPORT_FIELDS + Filter::DO_NOT_EXPORT_SUBFIELDS).map { |h| h.gsub(' ', '_') }
              table = Table.from_records(records, freeze: true, exportable_only: true)

              aggregate_failures 'row parsing' do
                records.each_with_index do |marc_record, row|
                  expected_headers = []
                  expected_values = []

                  marc_record.each_data_field.each do |df|
                    prefix = ColumnGroup.prefix_for(df)
                    df.subfields.each do |sf|
                      header = "#{prefix}#{sf.code}"
                      next if excluded_prefixes.any? { |h| header.start_with?(h) }

                      expected_headers << header
                      expected_values << sf.value
                    end
                  end

                  expected_index = 0
                  table.rows[row].values.each_with_index do |actual_value, index|
                    next unless actual_value

                    expected_header = expected_headers[expected_index]
                    actual_header = table.headers[index]
                    expect(actual_header).to start_with(expected_header)

                    expected_value = expected_values[expected_index]
                    expect(actual_value).to eq(expected_value)

                    expected_index += 1
                  end
                end
              end
            end
          end
        end

        describe :rows do

          it 'returns the rows' do
            records = MARC::XMLReader.read('spec/data/records-manual-search.xml', freeze: true).to_a
            table = Table.from_records(records)
            rows = table.rows
            expect(rows.size).to eq(records.size)
            expect(rows.all? { |r| r.is_a?(Row) }).to eq(true)
          end

          it 'is not cached when table is not frozen' do
            records = MARC::XMLReader.read('spec/data/records-manual-search.xml', freeze: true).to_a
            some_records = records[0...3]
            table = Table.from_records(some_records)
            rows1 = table.rows
            expect(rows1.size).to eq(some_records.size)
            expect(rows1.all? { |r| r.is_a?(Row) }).to eq(true)

            table << records.last
            rows2 = table.rows
            expect(rows2).not_to be(rows1)
            expect(rows1.size).to eq(some_records.size) # just to be sure
            expect(rows2.size).to eq(rows1.size + 1)
          end

          it 'is cached when table is frozen' do
            records = MARC::XMLReader.read('spec/data/records-manual-search.xml', freeze: true).to_a
            some_records = records[0...3]
            table = Table.from_records(some_records, freeze: true)
            rows = table.rows
            expect(rows.size).to eq(some_records.size)
            expect(table.rows).to be(rows)
          end

        end

        describe :each_row do
          let(:records) { MARC::XMLReader.read('spec/data/records-manual-search.xml', freeze: true).to_a }
          let(:table) { Table.from_records(records) }

          it 'yields each row' do
            rows = []
            table.each_row { |r| rows << r }
            expect(rows.size).to eq(records.size)
            expect(rows.all? { |r| r.is_a?(Row) }).to eq(true)
          end

          it 'returns an enumerator' do
            enum = table.each_row
            expect(enum).to be_an(Enumerator)
            rows = enum.each_with_object([]) { |r, a| a << r }
            expect(rows.size).to eq(records.size)
            expect(rows.all? { |r| r.is_a?(Row) }).to eq(true)
          end

          it 'is indexable' do
            rows = []
            table.each_row.with_index do |row, i|
              expect(rows[i]).to be_nil # just to be sure
              rows[i] = row
            end
            expect(rows.size).to eq(records.size)
          end
        end

        describe :to_csv do
          let(:records) { MARC::XMLReader.read('spec/data/records-manual-search.xml', freeze: true) }
          let(:table) { Table.from_records(records, freeze: true) }

          it 'outputs CSV' do
            csv_str = table.to_csv
            expect(csv_str).to be_a(String)

            CSV.parse(csv_str, headers: true).each_with_index do |csv_row, row|
              expect(csv_row.headers).to eq(table.headers)
              expect(csv_row.fields).to eq(table.rows[row].values)
            end
          end

          it 'accepts an IO object' do
            csv_str = StringIO.new.tap { |out| table.to_csv(out) }.string

            aggregate_failures 'rows' do
              CSV.parse(csv_str, headers: true).each_with_index do |csv_row, row|
                expect(csv_row.headers).to eq(table.headers)
                expect(csv_row.fields).to eq(table.rows[row].values)
              end
            end
          end

          it 'accepts a filename' do
            Dir.mktmpdir(File.basename(__FILE__, '.rb')) do |dir|
              out_path = File.join(dir, 'out.csv')
              table.to_csv(out_path)
              csv_str = File.read(out_path)

              CSV.parse(csv_str, headers: true).each_with_index do |csv_row, row|
                expect(csv_row.headers).to eq(table.headers)
                expect(csv_row.fields).to eq(table.rows[row].values)
              end
            end
          end
        end

      end
    end
  end
end
