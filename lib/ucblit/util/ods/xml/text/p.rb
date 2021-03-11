require 'ucblit/util/ods/xml/element_node'

module UCBLIT
  module Util
    module ODS
      module XML
        module Text
          class P < XML::ElementNode

            # ------------------------------------------------------------
            # Constant

            ESCAPABLE = ["\t", "\n", ' '].freeze

            # ------------------------------------------------------------
            # Accessors

            attr_reader :text

            # ------------------------------------------------------------
            # Initializer

            def initialize(text, doc:)
              super(:text, 'p', doc: doc)

              @text = text
              add_default_children!
            end

            # ------------------------------------------------------------
            # Private methods

            private

            def add_default_children!
              each_child_element_or_string { |c| children << c }
            end

            def each_child_element_or_string(last_char = nil, text_remaining = text, &block)
              last_char, text_remaining = yield_while_escaped(last_char, text_remaining, &block)
              last_char, text_remaining = yield_while_unescaped(last_char, text_remaining, &block)
              each_child_element_or_string(last_char, text_remaining, &block) unless text_remaining.empty?
            end

            def yield_while_unescaped(last_char, text_remaining, &block)
              unescaped, last_char = take_while_unescaped(last_char, text_remaining)
              unless unescaped.empty?
                block.call(unescaped)
                text_remaining = text_remaining[unescaped.size..]
              end

              [last_char, text_remaining]
            end

            def yield_while_escaped(last_char, text_remaining, &block)
              escaped_char_count = 0
              text_remaining.each_char do |c|
                break unless escape?(c, last_char)

                # TODO: collapse contiguous spaces with attribute 'text:c'
                #   https://docs.oasis-open.org/office/v1.2/os/OpenDocument-v1.2-os-part1.html#attribute-text_c
                block.call(escape_element_for(c))
                escaped_char_count += 1
                last_char = c
              end
              text_remaining = text_remaining[escaped_char_count..] unless escaped_char_count == 0

              [last_char, text_remaining]
            end

            def take_while_unescaped(last_char, text_remaining)
              unescaped = text_remaining.each_char.with_object('') do |c, result|
                break result if escape?(c, last_char)

                result << c
                last_char = c
              end
              [unescaped, last_char]
            end

            def escape?(c, last_char)
              ESCAPABLE.include?(c) && (last_char == ' ' || c != ' ')
            end

            def escape_element_for(c)
              raise ArgumentError, "Not an escapable character: #{c}" unless ESCAPABLE.include?(c)

              return S.new(doc: doc) if c == ' '
              return Tab.new(doc: doc) if c == "\t"
              return LineBreak.new(doc: doc) if c == "\n"
            end
          end

          # ------------------------------------------------------------
          # Helper classes

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
