require 'marc'

module BerkeleyLibrary
  module TIND
    module Mapping
      module TindRecordUtil

        class << self
          include TindRecordUtil
        end

        # 1) example tag_subfield_dic = { '245' => { b: 'subtitle', a: 'title' }, '336' => { a: nil } }
        #    when 'a' => nil, it will skip to update subfield a
        # 2) example: fields_removal_list = [%w[856 4 1]]  [tag, inicator1, indicator2]
        def update_record(record, tag_subfield_hash = nil, fields_removal_list = nil)
          return record unless tag_subfield_hash || fields_removal_list

          fields = update_fields(record, tag_subfield_hash)
          fields = remove_fields(fields, fields_removal_list)
          new_record = ::MARC::Record.new
          fields.each { |f| new_record.append(f) }
          new_record
        end

        private

        def update_fields(record, tag_subfield_hash)
          return record.fields unless valid_hash? tag_subfield_hash

          fields = []
          tags = tag_subfield_hash.keys
          record.fields.each do |field|
            tag = field.tag
            need_update = tags.include? tag
            fields << (need_update ? update_field(field, tag_subfield_hash[tag]) : field) # logic will be incorrect without brackets
          end
          fields
        end

        # example: fields_removal_list = [%w[856 4 1]]
        def remove_fields(fields, fields_removal_list)
          return fields unless valid_hash? fields_removal_list

          fields.reject { |f| excluding_field?(f, fields_removal_list) }
        end

        def excluding_field?(f, fields_removal_list)
          ls = [f.tag, clr(f.indicator1), clr(f.indicator2)]
          fields_removal_list.include? ls
        end

        def clr(str)
          str.strip.empty? ? '_' : str.strip
        end

        # subfield_dic example  { b: 'subtitle', a: 'title' }
        def update_field(field, subfield_hash)
          tag = field.tag
          indicators = [field.indicator1, field.indicator2]
          subfields = update_subfields(field, subfield_hash)
          Util.datafield(tag, indicators, subfields)
        end

        # example subfield_hash = { p:  'subtitle'}
        def update_subfields(field, subfield_hash)
          subfields = field.subfields.map { |sf| modify_subfield(sf, subfield_hash) }
          subfields.concat create_new_subfields(field, subfield_hash)
        end

        def modify_subfield(sf, subfield_hash)
          code = sf.code
          return sf unless (subfield_hash.keys.include? code) && subfield_hash[code]

          sf.value = subfield_hash[code]
          sf
        end

        def create_new_subfields(field, subfield_hash)
          subfields = []
          subfield_hash.each do |key, val|
            subfields << ::MARC::Subfield.new(key, val) if create_new_subfield?(field, key, val)
          end
          subfields
        end

        def create_new_subfield?(field, key, val)
          codes = field.subfields.map(&:code)
          warning_duplicated_subfield_code(codes)
          (!codes.include? key) && val
        end

        # suppose there are no duplicated subfield codes in a field
        # giving warning for investigation if finding any dublicated subfields in a field
        def warning_duplicated_subfield_code(codes)
          duplicated_codes = codes.select { |code| codes.count(code) > 1 }.uniq
          puts "Warning: duplicated subfields #{duplicated_codes.join(' ; ')}" unless duplicated_codes.empty?
        end

        def valid_hash?(hash)
          hash && !hash.empty?
        end
      end
    end
  end
end
