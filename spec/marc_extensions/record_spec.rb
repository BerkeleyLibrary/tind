require 'spec_helper'
require 'marc_extensions'

describe MARC::Record do
  let(:marc_record) { MARC::XMLReader.new('spec/data/record-187888.xml').first }

  describe :freeze do
    it 'freezes the fields' do
      expect(marc_record.fields).not_to be_frozen # just to be sure
      marc_record.freeze
      expect(marc_record.fields).to be_frozen
    end

    it 'freezes the leader' do
      expect(marc_record.leader).not_to be_frozen # just to be sure
      marc_record.freeze
      expect(marc_record.leader).to be_frozen
    end

    it 'freezes the fields' do
      marc_record.freeze
      marc_record.fields.each do |df|
        expect(df).to be_frozen
      end
    end

    it 'does not clobber the data' do
      expected = marc_record.to_hash
      marc_record.freeze
      expect(marc_record.to_hash).to eq(expected)
    end
  end

  describe :frozen? do
    it 'returns false neither fields nor leader are frozen' do
      expect(marc_record.leader).not_to be_frozen # just to be sure
      expect(marc_record.fields).not_to be_frozen # just to be sure
      expect(marc_record).not_to be_frozen
    end

    it 'returns false if only fields are frozen' do
      expect(marc_record.leader).not_to be_frozen # just to be sure
      expect(marc_record.fields).not_to be_frozen # just to be sure
      marc_record.leader.freeze
      expect(marc_record).not_to be_frozen
    end

    it 'returns false if only leader is frozen' do
      expect(marc_record.leader).not_to be_frozen # just to be sure
      expect(marc_record.fields).not_to be_frozen # just to be sure
      marc_record.fields.freeze
      expect(marc_record).not_to be_frozen
    end

    it 'returns false if neither fields nor leader are frozen' do
      expect(marc_record.leader).not_to be_frozen # just to be sure
      expect(marc_record.fields).not_to be_frozen # just to be sure
      expect(marc_record).not_to be_frozen
    end

    it 'returns true if both fields and leader are frozen' do
      expect(marc_record.leader).not_to be_frozen # just to be sure
      expect(marc_record.fields).not_to be_frozen # just to be sure
      marc_record.fields.freeze
      marc_record.leader.freeze
      expect(marc_record).to be_frozen
    end
  end

  describe :each_data_field do
    it 'returns only the data fields' do
      expected_tags = %w[024 035 245 336 505 505 505 505 505 505 540 852 856 856 901 902 902 980 982 991]
      dff = marc_record.each_data_field.to_a
      expect(dff.size).to eq(expected_tags.size)
      expect(dff.map(&:tag)).to eq(expected_tags)
    end

    it 'returns the data fields in order as they appear' do
      dff = marc_record.each_data_field.to_a
      dff_856 = dff.select { |df| df.tag == '856' }
      expect(dff_856.size).to eq(2) # just to be sure
      expected_sf9_values = %w[4a939fe2-2665-4c67-832b-b0e5267db449 0aacdd29-b467-4c5c-93ab-415069f431c0]
      expected_sf9_values.each_with_index do |expected, i|
        expect(dff_856[i]['9']).to eq(expected)
      end
    end

    it 'groups fields by tag even when disordered' do
      fields = marc_record.fields

      df_852_ix = fields.find_index { |df| df.tag == '852' }
      df_852 = fields.delete_at(df_852_ix)
      expect(df_852.tag).to eq('852') # just to be sure

      df_856_1, df_856_2 = fields[df_852_ix, 2]
      [df_856_1, df_856_2].each { |df| expect(df.tag).to eq('856') } # just to be sure

      fields.insert(df_852_ix + 1, df_852)
      expect(fields[df_852_ix, 3]).to eq([df_856_1, df_852, df_856_2]) # just to be sure

      dff = marc_record.each_data_field.to_a
      df_852_ix = dff.find_index { |df| df.tag == '852' }
      expect(dff[df_852_ix, 3]).to eq([df_852, df_856_1, df_856_2])
    end
  end

  describe :each_sorted_by_tag do
    let(:tags) do
      %w[856 852] # NOTE: not sorted
    end

    let(:expected) do
      [].tap do |ff|
        ff << marc_record['852']
        marc_record.each_by_tag('856') { |f| ff << f }
      end
    end

    it 'returns only fields with the specified tags, sorted, in original order' do
      result = []
      marc_record.each_sorted_by_tag(tags) { |f| result << f }
      expect(result).to eq(expected)
    end

    it 'returns nil if passed a block' do
      result = marc_record.each_sorted_by_tag(tags) { |_| next }
      expect(result).to be_nil
    end

    it 'returns an enum if not passed a block' do
      enum = marc_record.each_sorted_by_tag(tags)
      expect(enum).to be_a(Enumerator::Lazy)
      expect(enum.to_a).to eq(expected)
    end
  end

  describe :data_fields_by_tag do
    it 'groups fields by tag' do
      fields = marc_record.fields

      df_852_ix = fields.find_index { |df| df.tag == '852' }
      df_852 = fields.delete_at(df_852_ix)
      fields.insert(df_852_ix + 1, df_852)

      t2df = marc_record.data_fields_by_tag
      expect(t2df).to be_a(Hash)

      expected = {
        '024' => 1, '035' => 1,
        '245' => 1,
        '336' => 1,
        '505' => 6, '540' => 1,
        '852' => 1, '856' => 2,
        '901' => 1, '902' => 2, '980' => 1, '982' => 1, '991' => 1
      }

      expected.each do |tag, count|
        dff = t2df[tag]
        expect(dff).to be_a(Array)
        expect(dff.size).to eq(count)
        dff.each { |df| expect(df.tag).to eq(tag) }
      end
    end

    describe :each_sorted_by_tag do
      it 'returns all tags if not passed a tag list' do
        fields = marc_record.fields

        expected = fields.each_with_object({}) do |f, ex|
          (ex[f.tag] ||= []) << f
        end.values.flatten

        enum = marc_record.each_sorted_by_tag
        expect(enum.to_a).to eq(expected)
      end
    end
  end

  describe :each_control_field do
    it 'returns only the control fields' do
      expected_tags = %w[001 005]
      cff = marc_record.each_control_field.to_a
      expect(cff.size).to eq(expected_tags.size)
      expect(cff.map(&:tag)).to eq(expected_tags)
    end
  end
end
