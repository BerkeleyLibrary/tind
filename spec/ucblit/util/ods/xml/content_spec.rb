require 'spec_helper'

require 'rexml/document'

module UCBLIT
  module Util
    module ODS
      module XML
        describe Content do
          let(:content) { Content.new }

          describe :document_content do
            it 'returns a DocumentContent' do
              expect(content.document_content).to be_a(Office::DocumentContent)
            end
          end

          describe :to_xml do
            attr_reader :doc, :root

            before(:each) do
              xml_str = content.to_xml
              @doc = REXML::Document.new(xml_str)
              @root = doc.root
            end

            describe :root do

              it 'is a <document-content/> element' do
                expect(root).to be_a(REXML::Element)
                expect(root.prefix).to eq('office')
                expect(root.name).to eq('document-content')
                expect(root.namespace).to eq('urn:oasis:names:tc:opendocument:xmlns:office:1.0')
              end

              it 'includes all namespaces' do
                aggregate_failures('namespaces') do
                  Namespace.each do |ns|
                    expect(root["xmlns:#{ns.prefix}"]).to eq(ns.uri)
                  end
                end
              end

              describe '<scripts/>' do
                it 'includes a <scripts/> element' do
                  elem = root.elements[1]
                  expect(elem).to be_a(REXML::Element)
                  expect(elem.prefix).to eq('office')
                  expect(elem.name).to eq('scripts')
                end
              end

              describe '<font-face-decls/>' do
                attr_reader :decls

                before(:each) do
                  @decls = root.elements[2]
                end

                it 'includes a <font-face-decls/> element' do
                  expect(decls).to be_a(REXML::Element)
                  expect(decls.prefix).to eq('office')
                  expect(decls.name).to eq('font-face-decls')
                end

                it 'includes the default font face' do
                  face = decls.elements[1]
                  expect(face).to be_a(REXML::Element)
                  expect(face.prefix).to eq('style')
                  expect(face.name).to eq('font-face')

                  expect(face['style:name']).to eq('Arial')
                  expect(face['svg:font-family']).to eq('Arial')
                  expect(face['style:font-family-generic']).to eq('swiss')
                end
              end

              describe '<automatic-styles/>' do
                attr_reader :styles

                before(:each) do
                  @styles = root.elements[3]
                end

                it 'includes an <automatic-styles/> element' do
                  expect(styles).to be_a(REXML::Element)
                  expect(styles.prefix).to eq('office')
                  expect(styles.name).to eq('automatic-styles')
                end
              end

              describe '<body/>' do
                attr_reader :body

                before(:each) do
                  @body = root.elements[4]
                end

                it 'includes a <body/> element' do
                  expect(body).to be_a(REXML::Element)
                  expect(body.prefix).to eq('office')
                  expect(body.name).to eq('body')
                end

                it 'includes a <spreadsheet/> element' do
                  spreadsheet = body.elements[1]
                  expect(spreadsheet).to be_a(REXML::Element)
                  expect(spreadsheet.prefix).to eq('office')
                  expect(spreadsheet.name).to eq('spreadsheet')
                end
              end
            end

          end
        end
      end
    end
  end
end
