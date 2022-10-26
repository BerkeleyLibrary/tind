require 'csv'
require 'marc'
require 'berkeley_library/tind/mapping/alma_base'

module BerkeleyLibrary
  module TIND
    module Mapping
      module Util
        include AlmaBase

        class << self

          def csv_rows(file)
            rows = []
            CSV.foreach(file, headers: true, header_converters: :symbol, encoding: 'bom|utf-8') do |row|
              # puts row.headers
              rows << clr_row(row)
            end
            rows
          end

          def concatenation_symbol(str)
            str ? str.gsub('a', ' ') : ' '
          end

          def indicator(str)
            return [] unless str

            str.strip.gsub('_', ' ').split(',')
          end

          def tag_symbol(tag)
            "tag_#{tag}".to_sym
          end

          def datafield(tag, indicator, subfields)
            datafield = ::MARC::DataField.new(tag, indicator[0], indicator[1])
            subfields.each { |sf| datafield.append(sf) }
            datafield
          end

          def subfield(code, value)
            ::MARC::Subfield.new(code, value)
          end

          def subfield_hash(field)
            code_value_arr = field.to_hash[field.tag]['subfields']
            {}.tap { |i| code_value_arr.each(&i.method(:update)) }
          end

          # input an array of rules, example: [["a,b,c,d", "b", "--"],["o,p,q", "b", ""]]
          def symbols(rules)
            rules.map { |rule| concatenation_symbol(rule[2]).strip }
          end

          def remove_extra_symbol(rules, val)
            symbols = symbols(rules)
            symbols.each { |s| val = val.strip.delete_suffix(s) }
            val
          end

          def alma_datafield(tag, record)
            record.fields.each { |f| return f if f.tag.to_s == tag }
            nil
          end

          def qualified_alma_record?(alma_record)
            f_245 = alma_datafield('245', alma_record)
            f_245_a = f_245['a'].downcase

            val = 'Host bibliographic record'.downcase
            !f_245_a.start_with? val
          end

          # From DM - get testing MARC from xml file
          # @param xml [String] the XML to parse
          # @return [MARC::Record, nil] the MARC record from the specified XML
          def from_xml(xml)
            # noinspection RubyYardReturnMatch,RubyMismatchedReturnType
            all_from_xml(xml).first
          end

          def collection_config_correct?
            no_including = BerkeleyLibrary::TIND::Mapping::AlmaBase.including_origin_tags.empty?
            no_excluding = BerkeleyLibrary::TIND::Mapping::AlmaBase.excluding_origin_tags.empty?
            no_including || no_excluding
          end

          # subfield util
          def order_subfields(subfields, codes)
            found_subfields = []
            codes.each do |code|
              sfs = subfields.select { |subfield| subfield.code == code }
              found_subfields.concat sfs
            end
            not_found_subfields = subfields - found_subfields
            found_subfields.concat not_found_subfields
          end

          private

          def clr_row(row)
            row[:tag_origin] = format_tag(row[:tag_origin])
            row[:tag_destination] = format_tag(row[:tag_destination])
            row[:map_if_no_this_tag_existed] = format_tag(row[:map_if_no_this_tag_existed])
            row
          end

          # To ensure tag from csv file in three digits
          def format_tag(tag)
            # LDR is not a numeric tag
            return tag unless numeric? tag

            format('%03d', tag)
          end

          def numeric?(str)
            return false if str.nil?

            str.scan(/\D/).empty?
          end

          # Parses MARCXML.
          #
          # @param xml [String] the XML to parse
          # @return [MARC::XMLReader] the MARC records
          def all_from_xml(xml)
            input = StringIO.new(xml.scrub)
            MARC::XMLReader.new(input)
          end

        end
      end
    end
  end
end
