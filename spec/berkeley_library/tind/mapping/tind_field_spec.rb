require 'spec_helper'
require 'marc'

module BerkeleyLibrary
  module TIND
    module Mapping
      describe TindField do
        it 'Field 035' do
          f = TindField.f_035('Alibaba123')
          expect(f.tag).to eq '035'
          expect(f['a']).to eq 'Alibaba123'
        end

        it 'Field 035 derived from mms_id' do
          f = TindField.f_035_from_alma_id('991085821143406532', 'cu_news')
          expect(f.tag).to eq '035'
          expect(f['a']).to eq  '(cu_news)991085821143406532'
        end

        it 'Field 245$p' do
          f = TindField.f_245_p('fake_title_version')
          expect(f.tag).to eq '245'
          expect(f['p']).to eq 'fake_title_version'
        end

        it 'Field FFT' do
          f = TindField.f_fft('http://host/image.tif', 'news')
          expect(f.tag).to eq 'FFT'
          expect(f['a']).to eq  'http://host/image.tif'
          expect(f['d']).to eq  'news'
        end

        it 'Field 902$d' do
          f = TindField.f_902_d
          puts f['d']
          expect(f.tag).to eq '902'
          expect(f['d']).to match(/^\d{4}-\d{2}-\d{2}$/)
        end

        it 'Field 902$n' do
          f = TindField.f_902_n('YZ')
          expect(f.tag).to eq '902'
          expect(f['n']).to eq  'YZ'
        end

        it 'Field 982$p' do
          f = TindField.f_982_p('project name')
          expect(f.tag).to eq '982'
          expect(f['p']).to eq 'project name'
        end

        it 'Marc field' do
          f = TindField.f('998', 'g', 'file name')
          expect(f.tag).to eq '998'
          expect(f['g']).to eq 'file name'
        end
      end
    end
  end
end
