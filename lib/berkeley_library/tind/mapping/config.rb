require 'marc'

module BerkeleyLibrary
  module TIND
    module Mapping
      class Config

        class << self

          def one_to_one_map_file
            ENV.fetch('ONE_TO_ONE_MAP_FILE', File.expand_path('data/one_to_one_mapping.csv', __dir__))
          end

          def one_to_multiple_map_file
            ENV.fetch('ONE_TO_ONE_MAP_FILE', File.expand_path('data/one_to_multiple_mapping.csv', __dir__))
          end

          def no_duplicated_tags
            %w[245 260 852 901 902 980].freeze
          end

          def punctuations
            %w[, : ; / =].freeze
          end

          def clean_tags
            %w[245 260 300].freeze
          end

          def collection_subfield_names
            {
              '336' => ['a'],
              '852' => ['c'],
              '980' => ['a'],
              '982' => ['a', 'b'],
              '991' => ['a']
            }.freeze
          end

          #### Below methods for Rspec test  #####
          def test_xml_recod(xml_file)
            File.expand_path(xml_file, __dir__)
          end

          def alma_record(xml_file)
            file = File.open(test_xml_recod(xml_file))
            content = file.readlines.map(&:chomp)
            xml = content.join(' ')
            Util.from_xml(xml)
          end

          def test_record
            alma_record('data/record.xml')
          end

          def test_unqualified_record
            alma_record('data/record_not_qualified.xml')
          end

          # return 008 control field (having multiple mapping in csv file)
          def test_control_field
            test_record.fields.each { |f| return f if f.tag.to_s == '008' }
            nil
          end

          def test_datafield_880(subfield6_value)
            test_record.fields.each { |f| return f if f.tag.to_s == '880' && f['6'] == subfield6_value }
            nil
          end

          def test_datafield(tag)
            test_record.fields.each { |f| return f if f.tag.to_s == tag }
            nil
          end
        end
      end
    end
  end
end
