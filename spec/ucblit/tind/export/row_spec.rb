require 'spec_helper'

module UCBLIT
  module TIND
    # noinspection RubyYardParamTypeMatch
    module Export
      describe Table do
        describe Row do
          describe :values do

            it 'returns the values for the specified row' do
              records = MARC::XMLReader.read('spec/data/records-manual-search.xml', freeze: true).to_a
              table = Table.from_records(records)

              record = records[0]
              expected_values = record.data_fields.map(&:subfields).flatten.map(&:value)

              table << record
              values = table.rows[0].values

              # match_array gives a better error message than #eq() but doesn't enforce order
              expect(values).to match_array(expected_values)
              expect(values).to eq(expected_values)
            end

            it 'handles adding records with extra fields' do
              records = %w[184453 184458].map { |n| MARC::XMLReader.read("spec/data/record-#{n}.xml", freeze: true).first }
              table = Table.from_records(records, freeze: true)

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
              records = %w[184458 184453].map { |n| MARC::XMLReader.read("spec/data/record-#{n}.xml", freeze: true).first }
              table = Table.from_records(records, freeze: true)

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
              records = MARC::XMLReader.read('spec/data/disjoint-records.xml', freeze: true).to_a
              table = Table.from_records(records, freeze: true)

              vv_actual = (0...records.size).map { |row| table.rows[row].values }

              vv_expected = records.map { |r| r.data_fields.map(&:subfields).flatten.map(&:value) }
              vv_expected.each_with_index do |expected, index|
                expect(vv_actual[index]).not_to be_nil
                expect(vv_actual[index].compact).to eq(expected)
              end
            end

          end

          describe :each_value do
            it 'yields the values' do
              records = MARC::XMLReader.read('spec/data/disjoint-records.xml', freeze: true).to_a
              table = Table.from_records(records, freeze: true)

              vv_actual = table.each_row.with_object([]) do |row, vv_all|
                vv_row = [].tap do |vv|
                  row.each_value { |v| vv << v }
                end
                vv_all << vv_row
              end

              vv_expected = records.map { |r| r.data_fields.map(&:subfields).flatten.map(&:value) }
              vv_expected.each_with_index do |expected, index|
                expect(vv_actual[index]).not_to be_nil
                expect(vv_actual[index].compact).to eq(expected)
              end
            end

            it 'is indexable' do
              records = MARC::XMLReader.read('spec/data/disjoint-records.xml', freeze: true).to_a
              table = Table.from_records(records, freeze: true)

              vv_actual = table.each_row.with_object([]) do |row, vv_all|
                vv_row = [].tap do |vv|
                  row.each_value.with_index { |v, i| vv[i] = v }
                end
                vv_all << vv_row
              end

              vv_expected = records.map { |r| r.data_fields.map(&:subfields).flatten.map(&:value) }
              vv_expected.each_with_index do |expected, index|
                expect(vv_actual[index]).not_to be_nil
                expect(vv_actual[index].compact).to eq(expected)
              end
            end
          end
        end
      end
    end
  end
end
