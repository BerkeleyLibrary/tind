require 'marc'

module BerkeleyLibrary
  module TIND
    module Mapping
      module Misc

        #### referred tag ###
        def origin_mapping_tag(f)
          is_880_field?(f) ? referred_tag(f) : f.tag
        end

        # get the 880 referred tag.
        # An example $6 value: '650-05/$1', referred tag is 650
        def referred_tag(field)
          return nil unless subfield6?(field)

          field['6'].strip.split('-')[0]
        end

        # check a tag in subfield 6 of a 880 datafield
        def field_880_has_referred_tag?(tag, field)
          referred_tag_from_880 = referred_tag(field)
          return false unless referred_tag_from_880

          referred_tag_from_880 == tag
        end

        ### referred tag end ###

        # add subfield6 validation
        def check_subfield6_format(f)
          val = f['6']
          reg1 = %r{^\d{3}-\d{2}/}
          reg2 = /^\d{3}-\d{2}$/

          logger.warn("Unusual subfield6 format: #{val}; correct format examples: 1) 880-02 ; 2)246-02/$1") unless reg1.match(val) || reg2.match(val)
        end

        private

        # manipulate original values
        # Delete characters when occuring at the end of a subfield value
        def rm_punctuation(str)
          return str if str.empty? || str.nil?

          punctuations = Config.punctuations
          char = str[-1]
          return str unless punctuations.include? char

          rm_punctuation(str.delete_suffix!(char))
        end

        def clr_value(value)
          new_value = rm_punctuation(value)
          ['[', ']'].each { |v| value.gsub!(v, ' ') }
          new_value.strip
        end

        # input example: 1) 880-02 ; 2)246-02/$1
        def seq_no(value)
          # logger if not started with ***-** format
          value.split('/')[0].split('-')[1].to_i # nil.to_i => 0, ''.to_i = >0
        end

      end
    end
  end
end
