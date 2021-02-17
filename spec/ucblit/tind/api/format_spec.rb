require 'spec_helper'

module UCBLIT
  module TIND
    module API
      describe Format do
        describe :to_s do
          it 'returns the value' do
            expected = { Format::ID => 'id', Format::XML => 'xml', Format::FILES => 'files', Format::JSON => 'json' }
            expected.each do |fmt, val|
              expect(fmt.value).to eq(val)
              expect(fmt.to_s).to eq(val)
            end
          end
        end

        describe :to_str do
          it 'returns the value' do
            { Format::ID => 'id', Format::XML => 'xml', Format::FILES => 'files' }.each do |fmt, val|
              expect(fmt.value).to eq(val)
              expect(fmt.to_str).to eq(val)
            end
          end
        end

        describe :ensure_format do
          it 'returns nil for nil' do
            expect(Format.ensure_format(nil)).to be_nil
          end

          it 'returns a Format' do
            expect(Format.ensure_format(Format::XML)).to be(Format::XML)
          end

          it 'accepts a string' do
            expect(Format.ensure_format('xml')).to be(Format::XML)
          end

          it 'accepts a symbol' do
            expect(Format.ensure_format(:xml)).to be(Format::XML)
          end

          it 'rejects unsupported values' do
            expect { Format.ensure_format('CORBA') }.to raise_error(ArgumentError)
          end

          it 'rejects inconvertible values' do
            expect { Format.ensure_format(Object.new) }.to raise_error(ArgumentError)
          end
        end
      end
    end
  end
end
