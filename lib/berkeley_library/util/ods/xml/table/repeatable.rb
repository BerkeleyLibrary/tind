module BerkeleyLibrary
  module Util
    module ODS
      module XML
        module Table
          class Repeatable < XML::ElementNode

            attr_reader :table, :attr_name_num_repeated, :number_repeated

            def initialize(name, attr_name_num_repeated, number_repeated, table:)
              super(:table, name, doc: table.doc)
              @table = table
              @attr_name_num_repeated = attr_name_num_repeated
              self.number_repeated = number_repeated
            end

            def number_repeated=(value)
              raise ArgumentError, "Invalid number of repeats: #{value.inspect} => #{value.to_i}" if (repeats = value.to_i) <= 0

              if repeats == 1
                clear_attribute(attr_name_num_repeated)
              else
                set_attribute(attr_name_num_repeated, repeats)
              end

              @number_repeated = repeats
            end

            def increment_repeats!
              self.number_repeated += 1
            end

          end
        end
      end
    end
  end
end
