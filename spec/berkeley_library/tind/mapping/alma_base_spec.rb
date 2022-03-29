require 'spec_helper'
require 'tempfile'

module BerkeleyLibrary
  module TIND
    module Mapping
      describe 'AlmaBase' do
        extend BerkeleyLibrary::Logging
        let(:dummy_obj) { Class.new { extend AlmaBase } }
        let(:alma_record) { ::MARC::Record.new }
        let(:save_to_file) { Tempfile.new('xml') }
        let(:record_id) { Class.new { extend BerkeleyLibrary::Alma::RecordId } }
        let(:hash) { { '980' => ['pre_1912'] } }

        let(:qualified_alma_obj) { Alma.new('spec/data/mapping/record.xml') }
        let(:qualified_alm_record) { qualified_alma_obj.record }

        let(:un_qualified_alma_obj) { Alma.new('spec/data/mapping/record_not_qualified.xml') }
        let(:un_qualified_alm_record) { un_qualified_alma_obj.record }

        describe '# base_tind_record' do
          it 'input a qualified Alma record - return a tind record' do
            allow(dummy_obj).to receive(:qualified?).with(qualified_alm_record, 'C084093187').and_return(true)
            allow(dummy_obj).to receive(:tind_record).with('C084093187', qualified_alm_record, []).and_return(::MARC::Record.new)
            expect(dummy_obj.base_tind_record('C084093187', [], qualified_alm_record)).to be_a ::MARC::Record
          end

          it 'input an unqualified Alma record - return nil' do
            allow(dummy_obj).to receive(:qualified?).with(alma_record, 'C084093187').and_return(false)
            expect(dummy_obj.base_tind_record('C084093187', [], alma_record)).to eq nil
          end

          it 'no input Alma record but having a qualified Alma record from id - return tind record' do
            allow(dummy_obj).to receive(:qualified?).with(alma_record, 'C084093187').and_return(true)
            allow(dummy_obj).to receive(:tind_record).with('C084093187', alma_record, []).and_return(::MARC::Record.new)
            allow(dummy_obj).to receive(:alma_record_from).with('C084093187').and_return(::MARC::Record.new)
            expect(dummy_obj.base_tind_record('C084093187', [])).to be_a ::MARC::Record
          end

          it 'no input Alma record and having an unqualified Alma record from id - return nil' do
            allow(dummy_obj).to receive(:qualified?).with(alma_record, 'C084093187').and_return(false)
            allow(dummy_obj).to receive(:alma_record_from).with('C084093187').and_return(::MARC::Record.new)
            expect(dummy_obj.base_tind_record('C084093187', [])).to eq nil
          end

          it 'no input Alma record with a nil (record) from id  - return nil' do
            allow(dummy_obj).to receive(:alma_record_from).with('C084093187').and_return(nil)
            expect(dummy_obj.base_tind_record('C084093187', [])).to eq nil
          end
        end

        describe '# base_save' do
          it 'save tind record' do
            dummy_obj.base_save('C084093187', qualified_alm_record, save_to_file)
            expect(File.open(save_to_file.path).readlines[0]).to eq "<?xml version='1.0'?>\n"
          end
        end

        describe '# qualified?' do
          it 'qualified Alma record, return true' do
            expect(dummy_obj.send(:qualified?, qualified_alm_record, 'C084093187')).to be true
          end

          it 'unqualified Alma record, return false' do
            expect(dummy_obj.send(:qualified?, un_qualified_alm_record, 'C084093187')).to be false
          end
        end

        describe '# alma_record' do
          it 'get Alma record' do
            allow(record_id).to receive(:get_marc_record).and_return(::MARC::Record.new)
            allow(dummy_obj).to receive(:get_record_id).with('C084093187').and_return(record_id)
            expect(dummy_obj.send(:alma_record_from, 'C084093187')).to be_instance_of ::MARC::Record
          end
        end

        describe '# get_record_id' do
          it 'return BerkeleyLibrary::Alma::BarCode' do
            BerkeleyLibrary::TIND::Mapping::AlmaBase.is_barcode = true
            expect(dummy_obj.send(:get_record_id, 'C084093187')).to be_instance_of BerkeleyLibrary::Alma::BarCode
          end

          it 'return BerkeleyLibrary::Alma::MMSID' do
            BerkeleyLibrary::TIND::Mapping::AlmaBase.is_barcode = false
            expect(dummy_obj.send(:get_record_id, '991085821143406532')).to be_instance_of BerkeleyLibrary::Alma::MMSID

          end

          it 'return BerkeleyLibrary::Alma::BibNumber' do
            BerkeleyLibrary::TIND::Mapping::AlmaBase.is_barcode = false
            expect(dummy_obj.send(:get_record_id, 'b11082434')).to be_instance_of BerkeleyLibrary::Alma::BibNumber

          end
        end

        describe '# add_f_035' do
          it 'Add 035 from mms_id' do
            BerkeleyLibrary::TIND::Mapping::AlmaBase.is_035_from_mms_id = true
            expect(dummy_obj.send(:add_f_035, '991085821143406532', hash).tag).to eq '035'
          end

          it 'Not to add 035 from mms_id' do
            BerkeleyLibrary::TIND::Mapping::AlmaBase.is_035_from_mms_id = false
            expect(dummy_obj.send(:add_f_035, '991085821143406532', hash)).to eq nil
          end
        end

        describe '# tind_record, # derived_tind_fields' do
          BerkeleyLibrary::TIND::Mapping::AlmaBase.collection_parameter_hash = {
            '336' => ['Image'],
            '852' => ['East Asian Library'],
            '980' => ['pre_1912'],
            '982' => ['Pre 1912 Chinese Materials - short name', 'Pre 1912 Chinese Materials - long name'],
            '991' => []
          }
          let(:id) { '991085821143406532' }
          let(:tags) { %w[902 336 852 980 982 901 856] }
          let(:tags_with_035) { %w[902 336 852 980 982 901 856 035] }

          it ' get tind_record' do
            datafields = []
            marc_record = qualified_alm_record
            expect(dummy_obj.send(:tind_record, id, marc_record, datafields)).to be_instance_of ::MARC::Record
          end

          it 'get derived fields without 035' do
            expect(dummy_obj.send(:derived_tind_fields, id, id).map(&:tag)).to eq tags
          end

          it 'get derived fields with 035' do
            BerkeleyLibrary::TIND::Mapping::AlmaBase.is_035_from_mms_id = true
            expect(dummy_obj.send(:derived_tind_fields, id, id).map(&:tag)).to eq tags_with_035
          end

        end

      end
    end
  end
end
