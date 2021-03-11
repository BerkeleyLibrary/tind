require 'spec_helper'

module UCBLIT
  module Util
    module ODS
      module XML
        module Office
          describe AutomaticStyles do
            let(:doc) { Nokogiri::XML::Document.new }

            attr_reader :styles

            before(:each) do
              @styles = AutomaticStyles.new(doc: doc)
            end

            describe :add_child do
              it 'adds a style' do
                protected = false
                color = '#abcdef'

                style = Style::CellStyle.new('my-style', protected, color, styles: styles)
                styles.add_child(style)
                expect(styles.find_cell_style(protected, color)).to be(style)
              end

              it 'adds a non-style' do
                non_style = XML::Text::P.new('abcdef', doc: doc)
                styles.add_child(non_style)
              end
            end
          end
        end
      end
    end
  end
end
