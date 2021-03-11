require 'spec_helper'

module UCBLIT
  module Util
    module ODS
      module XML
        module Manifest
          describe Manifest do
            let(:doc) { Nokogiri::XML::Document.new }

            attr_reader :manifest

            before(:each) do
              @manifest = Manifest.new(doc: doc)
            end

            describe :add_child do
              it 'adds a FileEntry' do
                entry = FileEntry.new('foo.bar', 'foo/bar', manifest: manifest)
                manifest.add_child(entry)
              end

              it 'adds a non-FileEntry' do
                child = ElementNode.new(:office, 'test', doc: doc)
                manifest.add_child(child)
              end
            end
          end
        end
      end
    end
  end
end
