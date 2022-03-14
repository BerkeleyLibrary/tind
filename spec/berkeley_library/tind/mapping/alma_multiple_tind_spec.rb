# require 'spec_helper'

# module BerkeleyLibrary
#   module TIND
#     module Mapping
#       describe 'AlmaMultipleTIND' do

#         it ' # record' do
#           alma_single_tind =  AlmaMultipleTIND.new('991085821143406532')
#           allow(alma_single_tind).to receive(:alma_record).with('991085821143406532').and_return(::MARC::Record.new)
#           allow(alma_single_tind).to receive(:record).with([]).and_return(::MARC::Record.new)
#           expect(alma_single_tind.record([])).to be_instance_of ::MARC::Record
#         end
#       end
#     end
#   end
# end
