require 'nokogiri'

module BerkeleyLibrary
  module TIND
    module MARC
      class XMLBuilder
        attr_reader :marc_record

        def initialize(marc_record)
          @marc_record = marc_record
        end

        def build
          builder.doc.root.tap(&:unlink)
        end

        private

        def builder
          Nokogiri::XML::Builder.new do |xml|
            xml.record do
              add_leader(xml)
              marc_record.each_control_field { |cf| add_control_field(xml, cf) }
              marc_record.each_data_field { |df| add_data_field(xml, df) }
            end
          end
        end

        def add_leader(xml)
          leader = marc_record.leader
          return if leader.nil? || leader == ''

          # TIND uses <controlfield tag="000"/> instead of <leader/>
          leader_as_cf = ::MARC::ControlField.new('000', clean_leader(leader))
          add_control_field(xml, leader_as_cf)
        end

        def add_data_field(xml, df)
          xml.datafield(tag: df.tag, ind1: df.indicator1, ind2: df.indicator2) do
            df.subfields.each do |sf|
              xml.subfield(sf.value, code: sf.code)
            end
          end
        end

        def add_control_field(xml, cf)
          # TIND uses \ (0x5c), not space (0x32), for unspecified values in positional fields
          value = cf.value&.gsub(' ', '\\')
          xml.controlfield(value, tag: cf.tag)
        end

        def clean_leader(leader)
          leader.gsub(/[^\w|^\s]/, 'Z').tap do |ldr|
            ldr[20..23] = '4500' unless ldr[20..23] == '4500'
            ldr[6..6] = 'Z' if ldr[6..6] == ' '
          end
        end

      end
    end
  end
end
