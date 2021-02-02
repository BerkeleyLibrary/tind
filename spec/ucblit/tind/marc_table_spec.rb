require 'spec_helper'

module UCBLIT
  module TIND
    describe MARCTable do
      let(:table) { MARCTable.new }
      let(:records) { MARC::XMLReader.read_frozen('spec/data/records-search.xml').to_a }

      describe :<< do
        let(:record) { records.first }

        it 'adds a record' do
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
          expect(vv_actual.size).to eq(9) # just to be sure

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

            puts "#{row}) #{record['245']['a']}: #{record['500']['a']}"
            headers.each_with_index { |h, i| puts "\t#{h}\t#{values[i]}" }
            puts "\n" if row + 1 < records.size

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
    end
  end
end
