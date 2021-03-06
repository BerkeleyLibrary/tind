require 'spec_helper'

module BerkeleyLibrary
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

        describe :mime_type do
          it 'returns the correct MIME type' do
            {
              ExportFormat::CSV => 'text/csv',
              ExportFormat::ODS => 'application/vnd.oasis.opendocument.spreadsheet'
            }.each do |fmt, mime_type|
              expect(fmt.mime_type).to eq(mime_type)
            end
          end
        end

        describe :ensure_format do
          it 'rejects unsupported formats' do
            expect { ExportFormat.ensure_format(:wks) }.to raise_error(ArgumentError)
          end
        end

        describe :description do
          it 'returns a description' do
            ExportFormat.each do |fmt|
              expect(fmt.description).to be_a(String)
              expect(fmt.description).not_to be_empty
            end
          end
        end

        describe :DEFAULT do
          it 'defaults to ODS' do
            expect(ExportFormat::DEFAULT).to be(ExportFormat::ODS)
          end
        end

        describe :default? do
          it 'returns true for default, false otherwise' do
            ExportFormat.each do |fmt|
              expect(fmt.default?).to eq(fmt == ExportFormat::DEFAULT)
            end
          end
        end
      end
    end
  end
end
