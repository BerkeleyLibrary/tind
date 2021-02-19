require 'spec_helper'

module UCBLIT
  module TIND
    module Export
      describe ExportCommand do
        describe :usage do
          it 'returns the usage' do
            expect(ExportCommand.send(:usage)).to be_a(String)
          end
        end
      end
    end
  end
end
