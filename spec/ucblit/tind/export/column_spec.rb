require 'spec_helper'

module UCBLIT
  module TIND
    module Export
      describe Column do
        describe :each_value do
          let(:values) { %w[a b c d] }
          attr_reader :col

          before(:each) do
            cg = instance_double(ColumnGroup)
            allow(cg).to receive(:row_count).and_return(values.size)
            allow(cg).to receive(:value_at) { |r, _| values[r] }
            allow(cg).to receive(:prefix).and_return('99999')
            allow(cg).to receive(:index_in_tag).and_return(9)
            allow(cg).to receive(:subfield_codes).and_return(['9'])
            @col = Column.new(cg, 0)
          end

          it 'yields each value' do
            actual = [].tap do |vv|
              col.each_value { |v| vv << v }
            end
            expect(actual).to eq(values)
          end

          it 'returns an enumerator' do
            enum = col.each_value
            expect(enum.to_a).to eq(values)
          end

          it 'optionally returns the header' do
            enum = col.each_value(include_header: true)
            enum_values = enum.to_a
            expect(enum_values[0]).to eq(col.header)
            expect(enum_values[1..]).to eq(values)
          end
        end
      end
    end
  end
end
