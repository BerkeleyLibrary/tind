require 'spec_helper'
require 'roo'

require_relative 'export_matcher'

module BerkeleyLibrary
  # noinspection RubyYardParamTypeMatch
  module TIND
    describe Export do
      let(:basename) { File.basename(__FILE__, '.rb') }

      describe 'export' do
        let(:collection) { 'Bancroft Library' }

        describe 'with results' do

          let(:records) do
            (1..7)
              .map { |page| File.read("spec/data/records-api-search-p#{page}.xml") }
              .map { |p| BerkeleyLibrary::TIND::MARC::XMLReader.new(p, freeze: true).to_a }
              .flatten
          end
          let(:expected_table) { Export::Table.from_records(records, freeze: true, exportable_only: true) }

          before(:each) do
            search = instance_double(BerkeleyLibrary::TIND::API::Search)
            allow(search).to receive(:each_result).with(freeze: true).and_return(records.each)
            allow(BerkeleyLibrary::TIND::API::Search).to receive(:new).with(collection: collection).and_return(search)
          end

          describe :export do
            describe 'CSV formats' do
              it 'defaults to CSV' do
                actual_csv = Export.export(collection)
                expect(actual_csv).to match_table(expected_table)
              end

              [Export::ExportFormat::CSV, :csv, 'CSV'].each do |fmt|
                it "accepts #{fmt.inspect} as a format parameter" do
                  actual_csv = Export.export(collection, fmt)
                  expect(actual_csv).to match_table(expected_table)
                end
              end
            end

            describe 'ODS formats' do
              [Export::ExportFormat::ODS, :ods, 'ODS'].each_with_index do |fmt, i|
                it "accepts #{fmt.inspect} as a format parameter" do
                  Dir.mktmpdir(basename) do |dir|
                    output_path = File.join(dir, "#{basename}-#{i}.ods")
                    Export.export(collection, fmt, output_path)

                    ss = Roo::Spreadsheet.open(output_path)
                    begin
                      expect(ss).to match_table(expected_table)
                    ensure
                      ss.close
                    end
                  end
                end
              end
            end
          end
        end

        describe 'without results' do
          before(:each) do
            search = instance_double(BerkeleyLibrary::TIND::API::Search)
            allow(search).to receive(:each_result).with(freeze: true).and_return([].each)
            allow(BerkeleyLibrary::TIND::API::Search).to receive(:new).with(collection: collection).and_return(search)
          end

          it 'raises NoResultsError' do
            expect { Export.export(collection) }.to raise_error(Export::NoResultsError)
          end
        end

        describe 'CJK support' do
          let(:collection) { 'Houcun ju shi ji' }
          let(:records) { BerkeleyLibrary::TIND::MARC::XMLReader.new('spec/data/records-api-search-cjk-p1.xml', freeze: true).to_a }
          let(:expected_table) { Export::Table.from_records(records, freeze: true, exportable_only: true) }

          before(:each) do
            search = instance_double(BerkeleyLibrary::TIND::API::Search)
            allow(search).to receive(:each_result).with(freeze: true).and_return(records.each)
            allow(BerkeleyLibrary::TIND::API::Search).to receive(:new).with(collection: collection).and_return(search)
          end

          describe 'LibreOffice' do
            it 'works for LibreOffice' do
              Dir.mktmpdir(basename) do |dir|
                output_path = File.join(dir, "#{basename}.ods")
                Export.export(collection, 'ods', output_path)

                ss = Roo::Spreadsheet.open(output_path)
                begin
                  expect(ss).to match_table(expected_table)
                ensure
                  ss.close
                end
              end
            end

            it 'writes to an exploded directory' do
              Dir.mktmpdir(basename) do |dir|
                Export.export(collection, 'ods', dir)

                expected_paths_relative = %w[META-INF/manifest.xml styles.xml content.xml]
                expected_paths_absolute = expected_paths_relative.map do |path_relative|
                  joined_path = File.join(dir, path_relative)
                  File.absolute_path(joined_path)
                end

                expected_paths_absolute.each do |path_absolute|
                  expect(File.file?(path_absolute)).to eq(true)
                end
              end
            end
          end

          it 'works for CSV' do
            actual_csv = Export.export(collection, 'csv')
            expect(actual_csv).to match_table(expected_table)
          end
        end
      end

      describe 'with no results' do
        let(:collection) { 'Not a collection' }

        before(:each) do
          search = instance_double(BerkeleyLibrary::TIND::API::Search)
          # rubocop:disable Lint/EmptyBlock
          empty_enumerator = Enumerator.new {}
          # rubocop:enable Lint/EmptyBlock
          allow(search).to receive(:each_result).and_return(empty_enumerator)
          allow(BerkeleyLibrary::TIND::API::Search).to receive(:new).with(collection: collection).and_return(search)
        end

        describe :export do
          it 'raises an error' do
            Export::ExportFormat.each do |fmt|
              out = instance_double(IO)
              %i[reopen rewind << write].each { |m| expect(out).not_to receive(m) }
              expect { Export.export(collection, fmt, out) }.to raise_error(Export::NoResultsError)
            end
          end
        end
      end
    end
  end
end
