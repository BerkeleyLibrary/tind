require 'spec_helper'

module UCBLIT
  module TIND
    module Export
      describe ExportFormat do
        describe :to_str do
          it 'returns the value' do
            ExportFormat.each do |fmt|
              # rubocop:disable Style/StringConcatenation
              expect('' + fmt).to eq(fmt.value)
              # rubocop:enable Style/StringConcatenation
            end
          end
        end

        describe :ensure_format do
          it 'rejects unsupported formats' do
            expect { ExportFormat.ensure_format(:wks) }.to raise_error(ArgumentError)
          end
        end
      end
    end
  end
end
