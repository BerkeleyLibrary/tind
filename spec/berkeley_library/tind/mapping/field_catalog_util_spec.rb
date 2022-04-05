# require 'spec_helper'

# module BerkeleyLibrary
#   module TIND
#     module Mapping
#       describe FieldCatalogUtil do
#         let(:dummy_obj) { Class.new { extend FieldCatalogUtil } }
#         let(:qualified_alma_obj) { Alma.new('spec/data/mapping/record.xml') }
#         let(:qualified_alm_record) { qualified_alma_obj.record }

#         it 'excluding fast subject field' do
#           fields = qualified_alm_record.fields.select{|f| ['650', '245'].include? f.tag}
#           expect(fields.length).to eq 3
#           final_fields = dummy_obj.exluding_fields_with_fast_subject(fields)
#           expect(final_fields.length).to eq 2
#           expect(final_fields[0].tag).to eq '245'

#         end

#       end
#     end
#   end
# end
