require 'spec_helper'

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

      describe :values_for do
        it 'returns the values for the specified row' do
          record = records[0]
          expected_values = record.data_fields.map(&:subfields).flatten.map(&:value)

          table << record
          values = table.values_for(0)
          expect(values).to eq(expected_values)
        end

        it 'handles adding records with extra fields' do
          records = %w[184453 184458].map { |n| MARC::XMLReader.read_frozen("spec/data/record-#{n}.xml").first }

          records.each { |r| table << r }
          vv_actual = (0..1).map { |row| table.values_for(row) }

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

        it 'handles adding records with missing fields' do
          records = %w[184458 184453].map { |n| MARC::XMLReader.read_frozen("spec/data/record-#{n}.xml").first }

          records.each { |r| table << r }
          vv_actual = (0..1).map { |row| table.values_for(row) }

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

        it 'handles adding records with disjoint fields' do
          records = MARC::XMLReader.read_frozen('spec/data/disjoint-records.xml').to_a
          records.each { |r| table << r }
          vv_actual = (0...records.size).map { |row| table.values_for(row) }

          vv_expected = records.map { |r| r.data_fields.map(&:subfields).flatten.map(&:value) }
          vv_expected.each_with_index do |expected, index|
            expect(vv_actual[index]).not_to be_nil
            expect(vv_actual[index].compact).to eq(expected)
          end
        end
      end

      describe :headers do
        it 'aligns with the correct values' do
          records = MARC::XMLReader.read_frozen('spec/data/disjoint-records.xml').to_a
          table = MARCTable.from_records(records)

          headers = table.headers
          records.each_with_index do |record, row|
            values = table.values_for(row)
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
        let(:records) { MARC::XMLReader.read_frozen('spec/data/records-search.xml').to_a }
        let(:table) { MARCTable.from_records(records) }

        it 'returns the rows' do
          rows = table.rows
          expect(rows.size).to eq(records.size)
          expect(rows.all? { |r| r.is_a?(MARCTable::Row) }).to eq(true)
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
    end
  end
end
