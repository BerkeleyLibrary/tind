require 'spec_helper'

module UCBLIT
  module TIND
    module Export
      describe ExportCommand do
        before(:each) do
          @logger_orig = UCBLIT::TIND.logger
        end

        after(:each) do
          UCBLIT::TIND.logger = @logger_orig
        end

        describe :usage do
          it 'returns the usage' do
            expect(ExportCommand.send(:usage)).to be_a(String)
          end
        end

        describe :list_collection_names do
          it 'lists the collection names' do
            collections = UCBLIT::TIND::API::Collection.all_from_json(File.read('spec/data/collections.json'))
            allow(UCBLIT::TIND::API::Collection).to receive(:all).and_return(collections)

            out = StringIO.new
            ExportCommand.new('-l', out: out).execute!
            expect(out.string).to eq(File.read('spec/data/collection-names.txt'))
          end
        end

        describe :export_collection do
          it 'exports a collection' do
            format = 'csv'
            collection = 'Bancroft Library'
            out = instance_double(IO)

            expect(UCBLIT::TIND::Export).to receive(:export).with(collection, ExportFormat.ensure_format(format), out)
            ExportCommand.new('-f', format, collection, out: out).execute!
          end
        end

        describe '-v' do
          it 'configures a debug-level logger' do
            ExportCommand.new('-l', '-v')
            expect(UCBLIT::TIND.logger.level).to eq(0)
          end
        end

        describe 'error handling' do
          it 'prints usage and exits if given bad options' do
            stderr_orig = $stderr
            begin
              out = StringIO.new
              $stderr = out
              expect { ExportCommand.new('-not', '-a', '-valid', '-option') }.to raise_error(SystemExit) do |e|
                expect(e.status).not_to eq(0)
              end
              expected_usage = ExportCommand.send(:usage)
              expect(out.string).to include(expected_usage)
            ensure
              $stderr = stderr_orig
            end
          end

          it 'prints usage and exits in the event of an error' do
            err_class = HTTP::ResponseError
            err_msg = '403 Forbidden'
            expect(UCBLIT::TIND::Export).to receive(:export).and_raise(err_class, err_msg)
            stderr_orig = $stderr
            begin
              out = StringIO.new
              $stderr = out
              expect { ExportCommand.new('Bancroft Library').execute! }.to raise_error(SystemExit) do |e|
                expect(e.status).not_to eq(0)
              end
              expect(out.string).to include(err_msg)
            ensure
              $stderr = stderr_orig
            end
          end
        end
      end
    end
  end
end
