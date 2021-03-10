require 'ucblit/util/ods/xml/element_node'

module UCBLIT
  module Util
    module ODS
      module XML
        module Text
          class P < XML::ElementNode

            attr_reader :text

            def initialize(text, doc:)
              super(:text, 'p', doc: doc)

              @text = text
            end

            private

            def add_default_children
              text.scan(/((?<= ) |(?:[^ \t\n]+|(?<! ) )+|\t|\n)/).each do |seq|
                next children << S.new(doc: doc) if seq == ' '
                next children << Tab.new(doc: doc) if seq == "\t"
                next children << LineBreak.new(doc: doc) if seq == "\n"

                children << seq
              end
            end

          end

          class S < XML::ElementNode
            def initialize(doc:)
              super(:text, 's', doc: doc)
            end
          end

          class Tab < XML::ElementNode
            def initialize(doc:)
              super(:text, 'tab', doc: doc)
            end
          end

          class LineBreak < XML::ElementNode
            def initialize(doc:)
              super(:text, 'line-break', doc: doc)
            end
          end
        end
      end
    end
  end
end
