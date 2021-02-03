require 'spec_helper'

require 'csv'
require 'stringio'

module UCBLIT
  module TIND
    describe MARCTable do
      let(:table) { MARCTable.new }
      let(:records) { MARC::XMLReader.read_frozen('spec/data/records-search.xml').to_a }

      describe :<< do
        let(:record) { records.first }

        it 'adds rows record' do
          table << record
          expect(table.marc_records).to contain_exactly(record)
        end

        it 'adds multiple records' do
          records.each { |r| table << r }
          expect(table.marc_records).to eq(records)
        end
      end

      describe :headers do
        it 'aligns with the correct values' do
          records = MARC::XMLReader.read_frozen('spec/data/disjoint-records.xml').to_a
          table = MARCTable.from_records(records)

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

                    # TODO: hmm
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
          records = MARC::XMLReader.read_frozen('spec/data/records-search.xml').to_a
          table = records[0...3].each_with_object(MARCTable.new) { |r, t| t << r }
          table.freeze
          expect(table.row_count).to eq(3) # just to be sure
          original_headers = table.headers.dup

          # noinspection RubyModifiedFrozenObject
          expect { table << records.last }.to raise_error(FrozenError)
          expect(table.row_count).to eq(3)
          expect(table.headers).to eq(original_headers)
        end

        it 'freezes the MARC records array' do
          records = MARC::XMLReader.read_frozen('spec/data/records-search.xml').to_a
          table = records.each_with_object(MARCTable.new) { |r, t| t << r }
          table.freeze
          expect { table.marc_records << records.last }.to raise_error(FrozenError)
        end

        it 'freezes the columns' do
          records = MARC::XMLReader.read_frozen('spec/data/records-search.xml').to_a
          table = records.each_with_object(MARCTable.new) { |r, t| t << r }
          table.freeze

          expect { table.columns << Object.new }.to raise_error(FrozenError)
        end

        it 'freezes the rows' do
          records = MARC::XMLReader.read_frozen('spec/data/records-search.xml').to_a
          table = records.each_with_object(MARCTable.new) { |r, t| t << r }
          table.freeze

          expect { table.rows << Object.new }.to raise_error(FrozenError)
        end

        it 'returns self' do
          records = MARC::XMLReader.read_frozen('spec/data/records-search.xml').to_a
          table = records.each_with_object(MARCTable.new) { |r, t| t << r }
          expect(table.freeze).to be(table)
        end
      end

      describe :from_records do
        let(:records) { MARC::XMLReader.read_frozen('spec/data/records-search.xml').to_a }
        it 'reads the records' do
          table = MARCTable.from_records(records)
          expect(table.row_count).to eq(records.size)
        end

        it 'optionally freezes the table' do
          table = MARCTable.from_records(records, freeze: true)
          expect(table.frozen?).to eq(true)
        end
      end

      describe :rows do

        it 'returns the rows' do
          records = MARC::XMLReader.read_frozen('spec/data/records-search.xml').to_a
          table = MARCTable.from_records(records)
          rows = table.rows
          expect(rows.size).to eq(records.size)
          expect(rows.all? { |r| r.is_a?(MARCTable::Row) }).to eq(true)
        end

        it 'is not cached when table is not frozen' do
          records = MARC::XMLReader.read_frozen('spec/data/records-search.xml').to_a
          some_records = records[0...3]
          table = MARCTable.from_records(some_records)
          rows1 = table.rows
          expect(rows1.size).to eq(some_records.size)
          expect(rows1.all? { |r| r.is_a?(MARCTable::Row) }).to eq(true)

          table << records.last
          rows2 = table.rows
          expect(rows2).not_to be(rows1)
          expect(rows1.size).to eq(some_records.size) # just to be sure
          expect(rows2.size).to eq(rows1.size + 1)
        end

        it 'is cached when table is frozen' do
          records = MARC::XMLReader.read_frozen('spec/data/records-search.xml').to_a
          some_records = records[0...3]
          table = MARCTable.from_records(some_records, freeze: true)
          rows = table.rows
          expect(rows.size).to eq(some_records.size)
          expect(table.rows).to be(rows)
        end

        describe MARCTable::Row do
          describe :values do

            it 'returns the values for the specified row' do
              records = MARC::XMLReader.read_frozen('spec/data/records-search.xml').to_a
              table = MARCTable.from_records(records)

              record = records[0]
              expected_values = record.data_fields.map(&:subfields).flatten.map(&:value)

              table << record
              values = table.rows[0].values
              expect(values).to eq(expected_values)
            end

            it 'handles adding records with extra fields' do
              records = %w[184453 184458].map { |n| MARC::XMLReader.read_frozen("spec/data/record-#{n}.xml").first }
              table = MARCTable.from_records(records, freeze: true)

              vv_actual = (0..1).map { |row| table.rows[row].values }

              vv_expected = records.map { |r| r.data_fields.map(&:subfields).flatten.map(&:value) }
              vv_expected.each_with_index do |expected, index|
                expect(vv_actual[index].compact).to eq(expected)
              end

              # 184458 has 260 & 269, 184453 doesn't
              vv_184453 = vv_actual[0]
              vv_184458 = vv_actual[1]
              expect(vv_184453.size).to eq(vv_184458.size)
              expect(vv_184453[3..4]).to contain_exactly(nil, nil)
            end

            it 'handles records with missing fields' do
              records = %w[184458 184453].map { |n| MARC::XMLReader.read_frozen("spec/data/record-#{n}.xml").first }
              table = MARCTable.from_records(records, freeze: true)

              vv_actual = (0..1).map { |row| table.rows[row].values }

              vv_expected = records.map { |r| r.data_fields.map(&:subfields).flatten.map(&:value) }
              vv_expected.each_with_index do |expected, index|
                expect(vv_actual[index].compact).to eq(expected)
              end

              # 184458 has 260 & 269, 184453 doesn't
              vv_184458 = vv_actual[0]
              vv_184453 = vv_actual[1]
              expect(vv_184453.size).to eq(vv_184458.size)
              expect(vv_184453[3..4]).to contain_exactly(nil, nil)
            end

            it 'handles records with disjoint fields' do
              records = MARC::XMLReader.read_frozen('spec/data/disjoint-records.xml').to_a
              table = MARCTable.from_records(records, freeze: true)

              vv_actual = (0...records.size).map { |row| table.rows[row].values }

              vv_expected = records.map { |r| r.data_fields.map(&:subfields).flatten.map(&:value) }
              vv_expected.each_with_index do |expected, index|
                expect(vv_actual[index]).not_to be_nil
                expect(vv_actual[index].compact).to eq(expected)
              end
            end

          end
        end

      end

      describe :each_row do
        let(:records) { MARC::XMLReader.read_frozen('spec/data/records-search.xml').to_a }
        let(:table) { MARCTable.from_records(records) }

        it 'yields each row' do
          rows = []
          table.each_row { |r| rows << r }
          expect(rows.size).to eq(records.size)
          expect(rows.all? { |r| r.is_a?(MARCTable::Row) }).to eq(true)
        end

        it 'returns an enumerator' do
          enum = table.each_row
          expect(enum).to be_an(Enumerator)
          rows = enum.each_with_object([]) { |r, a| a << r }
          expect(rows.size).to eq(records.size)
          expect(rows.all? { |r| r.is_a?(MARCTable::Row) }).to eq(true)
        end
      end

      describe :to_csv do
        let(:records) { MARC::XMLReader.read_frozen('spec/data/records-search.xml') }
        let(:table) { MARCTable.from_records(records, freeze: true) }

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

          CSV.parse(csv_str, headers: true).each_with_index do |csv_row, row|
            expect(csv_row.headers).to eq(table.headers)
            expect(csv_row.fields).to eq(table.rows[row].values)
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
