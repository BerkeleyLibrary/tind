require 'marc'
require 'berkeley_library/tind/mapping/tind_control_subfield'

module BerkeleyLibrary
  module TIND
    module Mapping

      class TindFieldFromMultipleMap
        include CsvMultipleMapper
        include Util
        include TindControlSubfield

        def initialize(controlfield, current_datafields)
          @from_controlfield = controlfield
          @current_tags = current_datafields.map(&:tag)
        end

        def to_datafields
          datafields = []
          control_rules = rules_on_controldatafield

          if control_rules
            control_rules.each do |rule|
              df = to_datafield(rule)
              datafields << df if df
            end
          end

          datafields
        end

        private

        # one control field may have multiple rules
        def rules_on_controldatafield
          tag = @from_controlfield.tag
          sym = Util.tag_symbol(tag)
          rules[sym]
        end

        # Check mapped current datafields has the pre-existed tag defined in the row (rule) of csv file
        def pre_exsited_tag?(rule)
          @current_tags.include? rule.pre_existed_tag.to_s
        end

        # get a datafield on a rule (row in csv file)
        def to_datafield(rule)
          return nil if pre_exsited_tag?(rule)

          to_value = extract_value(rule, @from_controlfield.value)
          return nil unless to_value

          extracted_field(rule, to_value)
        end

      end
    end
  end
end
