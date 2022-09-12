require 'marc'

module Batch
  module TindRecordUtil

    class << self
      include TindRecordUtil
    end

    # 1) tag_subfield_hash: a hash to add a new, or update an existing subfield to a field in a TIND Marc record
    #    If a subfield existed, it will replace the subfield, otherwise, add a new subfield
    #    when 'a' => nil, it will skip add/update to subfield,
    #    It can be useed in a case: only need to add/update subfields of specific records in a collection
    #    This is an example: tag_subfield_hash = { '245' => { 'b' => 'subtitle', 'a' => 'title' }, '336' => { 'a' => nil } }
    # 2) fields_removal_list: an array including fields' informat: tag, indicators - "[tag, inicator1, indicator2]".
    #    This list is to remove fields in a record.
    #    An example fields_removal_list = [%w[856 4 1], %w[041 _ _]].
    #    '_' means an empty indicator ''
    # 3) How to use it:
    #   a.  add/update subfields of existed fields in record: TindRecordUtil.update_record(record, tag_subfield_hash)
    #   b.  remove a list of fields in the record: TindRecordUtil.update_record(record, nil, fields_removal_list)
    #   c.  both a. and b. : TindRecordUtil.update_record(record, tag_subfield_hash, fields_removal_list)
    def update_record(record, tag_subfield_hash = nil, fields_removal_list = nil)
      return record unless valid_hash?(tag_subfield_hash) || valid_hash?(fields_removal_list)

      fields = record.fields
      final_fields = tag_subfield_hash ? subfields_to_existed_fields(fields, tag_subfield_hash) : fields
      remove_fields(final_fields, fields_removal_list) if fields_removal_list
      new_record(final_fields)
    end


    private

    def subfields_to_existed_fields(fields, tag_subfield_hash)
      updated_fields = []
      tags = tag_subfield_hash.keys
      fields.each do |field|
        tag = field.tag
        need_change_subfield = tags.include? tag
        updated_fields << (need_change_subfield ? field_changed_subfields(field, tag_subfield_hash[tag]) : field)
      end
      fields
    end

    # example: fields_removal_list = [%w[856 4 1]]
    def remove_fields(fields, fields_removal_list)
      fields.reject! { |f| field_in_removal_list?(f, fields_removal_list) }
    end

    def new_record(fields)
      record = ::MARC::Record.new
      fields.each { |f| record.append(f) }
      record
    end

    # subfield_hash example  { 'b' => 'subtitle', 'a' => 'title' }
    def field_changed_subfields(field, subfield_hash)
      tag = field.tag
      indicators = [field.indicator1, field.indicator2]
      subfields = changed_subfields(field, subfield_hash)
      new_datafield(tag, indicators, subfields)
    end

    # example subfield_hash = { 'p' =>  'subtitle'}
    def changed_subfields(field, subfield_hash)
      subfields = field.subfields
      codes = subfields.map(&:code)
      warning_duplicated_subfield_code(codes)

      keys = subfield_hash.keys

      keys_no_related_codes = keys - codes
      keys_with_related_codes = keys - keys_no_related_codes

      updated_subfields(subfields, keys_with_related_codes, subfield_hash)

      subfields.concat new_subfields(field, keys_no_related_codes, subfield_hash)
      subfields
    end

    # example subfield_hash = { 'p' =>  'subtitle'}
    def updated_subfields(subfields, existed_codes, subfield_hash)
      subfields.each do |subfield|
        code = subfield.code
        next unless existed_codes.include? code

        val = subfield_hash[code]
        next unless val

        subfield.value = val
      end
    end

    def new_subfields(_field, new_codes, subfield_hash)
      subfields = []
      subfield_hash.each do |key, val|
        next unless val

        subfields << ::MARC::Subfield.new(key, val) if new_codes.include? key
      end
      subfields
    end

    def field_in_removal_list?(f, fields_removal_list)
      ls = [f.tag, clr(f.indicator1), clr(f.indicator2)]
      fields_removal_list.include? ls
    end

    def clr(str)
      str.strip.empty? ? '_' : str.strip
    end

    def new_datafield(tag, indicator, subfields)
      datafield = ::MARC::DataField.new(tag, indicator[0], indicator[1])
      subfields.each { |sf| datafield.append(sf) }
      datafield
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
