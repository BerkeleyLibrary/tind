require 'marc'
require 'berkeley_library/tind/mapping/tind_control_subfield'

module BerkeleyLibrary
  module TIND
    require 'marc'
    module Mapping

      class TindFieldFromLeader
        include CsvMultipleMapper
        include Util
        include TindControlSubfield

        def initialize(record)
          @leader_value = record.leader
        end

        def to_datafields
          leader_rules = rules[Util.tag_symbol('LDR')]
          return [] unless @leader_value && leader_rules

          extracted_fields_from_leader(leader_rules, @leader_value)
        end
      end
    end
  end
end
