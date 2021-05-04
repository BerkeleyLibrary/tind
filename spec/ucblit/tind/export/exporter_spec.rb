require 'spec_helper'
require 'roo'

require_relative 'export_matcher'

module UCBLIT
  module TIND
    module Export
      describe Exporter do
        let(:collection) { 'Bancroft Library' }

        describe 'base class' do
          let(:exporter) { Exporter.new(collection) }

          it "doesn't implement :export" do
            expect { exporter.export }.to raise_error(NoMethodError)
          end

          it "doesn't respond to :export" do
            expect(exporter.respond_to?('export')).to eq(false)
            expect(exporter.respond_to?(:export)).to eq(false)
          end
        end

        Export::ExportFormat.each do |export_format|

          attr_reader :search

          before(:each) do
            @search = instance_double(UCBLIT::TIND::API::Search)
            allow(UCBLIT::TIND::API::Search).to receive(:new).with(collection: collection).and_return(search)
          end

          describe export_format.to_s do
            let(:ext) { export_format.to_s.downcase }
            let(:exporter) { export_format.exporter_for(collection) }

            it 'responds to :export' do
              expect(exporter.respond_to?('export')).to eq(true)
              expect(exporter.respond_to?(:export)).to eq(true)
            end

            describe 'with results' do
              let(:records) do
                (1..7)
                  .map { |page| File.read("spec/data/records-api-search-p#{page}.xml") }
                  .map { |p| UCBLIT::TIND::MARC::XMLReader.new(p, freeze: true).to_a }
                  .flatten
              end

              before(:each) do
                allow(search).to receive(:each_result).with(freeze: true).and_return(records.each)
              end

              describe :any_results? do
                it 'returns true' do
                  expect(exporter.any_results?).to eq(true)
                end

                it 'caches the search result' do
                  2.times { exporter.any_results? }
                  expect(search).to have_received(:each_result).with(freeze: true).exactly(1).time
                end
              end

              describe :export do
                it 'exports' do
                  exported_data = exporter.export
                  expect(exported_data).not_to be_nil
                end

                it 'caches search results' do
                  2.times { expect(exporter.export).not_to be_nil }
                  expect(search).to have_received(:each_result).with(freeze: true).exactly(1).time
                end

                it 'caches search results from a previous `has_results?` invocation' do
                  exporter.any_results?
                  exporter.export
                  expect(search).to have_received(:each_result).with(freeze: true).exactly(1).time
                end
              end
            end

            describe 'without results' do
              before(:each) do
                allow(search).to receive(:each_result).with(freeze: true).and_return([].each)
              end

              describe :any_results? do
                it 'returns false' do
                  expect(exporter.any_results?).to eq(false)
                end

                it 'caches the search result' do
                  2.times { exporter.any_results? }
                  expect(search).to have_received(:each_result).with(freeze: true).exactly(1).time
                end
              end

              describe :export do
                it 'raises NoResultsError' do
                  expect { exporter.export }.to raise_error(NoResultsError)
                end

                it 'caches the failed search result' do
                  2.times do
                    expect { exporter.export }.to raise_error(NoResultsError)
                  end
                  expect(search).to have_received(:each_result).with(freeze: true).exactly(1).time
                end

                it 'caches the failed search result from a previous `has_results?` invocation' do
                  exporter.any_results?
                  expect { exporter.export }.to raise_error(NoResultsError)
                  expect(search).to have_received(:each_result).with(freeze: true).exactly(1).time
                end
              end
            end
          end
        end
      end
    end
  end
end
