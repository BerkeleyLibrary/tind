require 'spec_helper'

module BerkeleyLibrary
  module TIND
    module Mapping
      describe AlmaSingleTIND do
        let(:additona_245_field) { [Util.datafield('245', [' ', ' '], [Util.subfield('a', 'fake 245 a')])] }
        let(:marc_obj) { (::MARC::Record.new).append(additona_245_field) }

        before { BerkeleyLibrary::Alma::Config.default! }
        after { BerkeleyLibrary::Alma::Config.send(:clear!) }

        it ' get tind record' do
          alma_single_tind = BerkeleyLibrary::TIND::Mapping::AlmaSingleTIND.new

          allow(alma_single_tind).to receive(:base_tind_record).with('991085821143406532', additona_245_field).and_return(marc_obj)
          expect(alma_single_tind.record('991085821143406532', additona_245_field)).to be marc_obj
        end

        describe 'TIND record mapping' do
          let(:coll_param_hash) do
            {
              '336' => ['Image'],
              '852' => ['East Asian Library'],
              '980' => ['pre_1912'],
              '982' => ['Pre 1912 Chinese Materials - short name', 'Pre 1912 Chinese Materials - long name'],
              '991' => []
            }
          end

          let(:id) { '991032333019706532' }
          let(:marc_url) { BerkeleyLibrary::Alma::RecordId.parse(id).marc_uri.to_s }
          let(:logger) { BerkeleyLibrary::Logging.logger }

          before do
            AlmaBase.collection_parameter_hash = coll_param_hash
            AlmaBase.is_035_from_mms_id = true
          end

          after do
            AlmaBase.collection_parameter_hash = nil
            AlmaBase.is_035_from_mms_id = false
          end

          it 'transforms a record' do
            marc_xml = File.read('spec/data/mapping/991032333019706532-sru.xml')
            stub_request(:get, marc_url).to_return(body: marc_xml)

            expect(logger).not_to receive(:warn)

            mapper = BerkeleyLibrary::TIND::Mapping::AlmaSingleTIND.new
            url = "https://digitalassets.lib.berkeley.edu/pre1912ChineseMaterials/ucb/ready/#{id}/#{id}_v001_0064.jpg"
            fft = BerkeleyLibrary::TIND::Mapping::TindField.f_fft(url, 'v001_0064')
            tind_record = mapper.record(id, [fft])

            expect(tind_record).to be_a(::MARC::Record)
            expect(tind_record['FFT']).to eq(fft)

            expect(tind_record['901']['m']).to eq(id)
            expect(tind_record['035']['a']).to eq("(pre_1912)#{id}")

            alma_record = ::MARC::XMLReader.read(StringIO.new(marc_xml)).first
            sf_245a_expected = alma_record.spec('245$a{$6=\880-02}').first
            sf_245_value_expected = sf_245a_expected.value.sub(/[^[:alnum:]]+$/, '')

            sf_245a_actual = tind_record.spec('245$a{$6=\880-02}').first
            sf_245a_value_actual = sf_245a_actual.value
            expect(sf_245a_value_actual).to eq(sf_245_value_expected)
          end

          it 'handles pathological records without an 001 control field' do
            marc_xml = File.read('spec/data/mapping/991032333019706532-sru.xml')
              .sub('<controlfield tag="001">991032333019706532</controlfield>', '')
            stub_request(:get, marc_url).to_return(body: marc_xml)

            expect(logger).to receive(:warn).with("#{id} has no Control Field 001")

            mapper = BerkeleyLibrary::TIND::Mapping::AlmaSingleTIND.new
            url = "https://digitalassets.lib.berkeley.edu/pre1912ChineseMaterials/ucb/ready/#{id}/#{id}_v001_0064.jpg"
            fft = BerkeleyLibrary::TIND::Mapping::TindField.f_fft(url, 'v001_0064')
            expect { mapper.record(id, [fft]) }.to raise_error(ArgumentError)
          end
        end
      end
    end
  end
end
