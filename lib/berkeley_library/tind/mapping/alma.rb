require 'marc'

module BerkeleyLibrary
  module TIND
    module Mapping
      class Alma
        include Util

        attr_reader :record

        def initialize(xml_file)
          @record = alma_record(xml_file)
        end

        def control_field
          @record.fields.each { |f| return f if f.tag.to_s == '008' }
          nil
        end

        def field_880(subfield6_value)
          @record.fields.each { |f| return f if f.tag.to_s == '880' && f['6'] == subfield6_value }
          nil
        end

        def field(tag)
          @record.fields.each { |f| return f if f.tag.to_s == tag }
          nil
        end

        private

        def alma_record(xml_file)
          file = File.open(xml_file)
          content = file.readlines.map(&:chomp)
          xml = content.join(' ')
          Util.from_xml(xml)
        end

      end
    end
  end
end
