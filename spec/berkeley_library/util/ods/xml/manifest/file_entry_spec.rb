require 'spec_helper'

module BerkeleyLibrary
  module Util
    module ODS
      module XML
        module Manifest
          describe FileEntry do
            let(:doc) { Nokogiri::XML::Document.new }
            let(:manifest) { Manifest.new(doc: doc) }

            describe :new do
              it 'guesses the media type' do
                entry = FileEntry.new('foo.xml', manifest: manifest)
                expect(entry.media_type).to eq('text/xml')
              end

              it 'rejects unknown types' do
                expect { FileEntry.new('foo.bar', manifest: manifest) }.to raise_error(ArgumentError)
              end
            end
          end
        end
      end
    end
  end
end
