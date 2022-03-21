require 'marc'

module BerkeleyLibrary
  module TIND
    module Mapping
      module MatchTindField

        # return regular fields without matched 880 fields
        # return 880 fields without matched regular fields
        def un_matched_fields_880(fields)
          unmached_fields = []

          str_arr_from_880 = subfield6_values_from_880_fields(fields)
          str_arr_from_regular = subfield6_values_from_regular_fields(fields)

          fields_tobe_validated = fields_need_880_validation(fields)

          fields_880_tobe_validated = fields_tobe_validated.select { |f| is_880_field?(f) }
          fields_regular_tobe_validated = fields_tobe_validated.reject { |f| is_880_field?(f) }

          unmached_fields.concat un_matched_fields(fields_880_tobe_validated, str_arr_from_regular)
          unmached_fields.concat un_matched_fields(fields_regular_tobe_validated, str_arr_from_880)

          log_warning(unmached_fields)
        end

        def check_abnormal_formated_subfield6(fields)
          fields.each { |f| check_subfield6_format(f) if check_subfield6?(f) }
        end

        private

        def subfield6_values_from_880_fields(fields)
          formated_subfield6_value_arr(fields_by(fields) { |f| is_880_field?(f) })
        end

        def subfield6_values_from_regular_fields(fields)
          formated_subfield6_value_arr(fields_by(fields) { |f| !is_880_field?(f) })
        end

        def fields_need_880_validation(fields)
          fields_with_subfield6(fields).reject { |f| subfield6_endwith_00?(f) }
        end

        # return true when field has a matched 880 field,
        # or an 880 field has a matched regular field
        def match?(f, arr)
          str = formated_subfield6_value(f)
          arr.include? str
        end

        def un_matched_fields(fields, arr)
          fds = []
          fields.each { |f| fds << f unless match?(f, arr) }
          fds
        end

        def log_warning(fields)
          warning_message_for_rspec = []
          fields.each do |f|
            msg = "No matching: #{f.tag} $ #{f['6']} "
            warning_message_for_rspec << msg
            logger.warn(msg)
          end
          warning_message_for_rspec
        end

        def check_subfield6?(f)
          return false if ::MARC::ControlField.control_tag?(f.tag)

          f['6'] ? true : false
        end

      end
    end
  end
end
