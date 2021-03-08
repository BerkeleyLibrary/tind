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
            allow(cg).to(receive(:value_at)) { |r, _| values[r] }
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
        end
      end
    end
  end
end
