require 'spec_helper'

module BerkeleyLibrary
  module TIND
    module API
      describe DateRange do

        let(:t1) { Time.new(2021, 2, 15, 16, 23, 14, '-08:00') }
        let(:t2) { Time.new(2021, 2, 16, 19, 23, 14, '-07:00') }

        it 'is always in UTC' do
          expect(t1.utc_offset).to eq(-28_800) # just to be sure
          expect(t2.utc_offset).to eq(-25_200) # just to be sure

          date_range = DateRange.new(from_time: t1, until_time: t2)
          expect(date_range.from_time).to eq(t1.getutc)
          expect(date_range.until_time).to eq(t2.getutc)

          expect(t1.utc_offset).to eq(-28_800), 'DateRange initializer should not modify input from_time'
          expect(t2.utc_offset).to eq(-25_200), 'DateRange initializer should not modify input until_time'
        end

        it 'rejects invalid ranges' do
          expect { DateRange.new(from_time: t2, until_time: t1) }.to raise_error(ArgumentError)
        end

        describe :mtime do
          it 'defaults to false' do
            date_range = DateRange.new(from_time: t1, until_time: t2)
            expect(date_range.mtime?).to eq(false)

            params = date_range.to_params
            expect(params.key?(:dt)).to eq(false)
          end

          it 'can be set to true' do
            date_range = DateRange.new(from_time: t1, until_time: t2, mtime: true)
            expect(date_range.mtime?).to eq(true)

            params = date_range.to_params
            expect(params[:dt]).to eq('m')
          end
        end

        describe :to_params do
          let(:tz_utc) { TZInfo::Timezone.get('UTC') }
          let(:tz_local) { TZInfo::Timezone.get('Antarctica/South_Pole') }

          before(:each) do
            @tz_orig = BerkeleyLibrary::TIND::Config.instance_variable_get(:@timezone)
          end

          after(:each) do
            BerkeleyLibrary::TIND::Config.instance_variable_set(:@timezone, @tz_orig)
          end

          it 'formats the dates' do
            BerkeleyLibrary::TIND::Config.timezone = tz_utc

            date_range = DateRange.new(from_time: t1, until_time: t2)
            params = date_range.to_params
            expect(params[:d1]).to eq('2021-02-16 00:23:14')
            expect(params[:d2]).to eq('2021-02-17 02:23:14')
          end

          it 'formats the dates in the configured timezone' do
            BerkeleyLibrary::TIND::Config.timezone = tz_local

            date_range = DateRange.new(from_time: t1, until_time: t2)
            params = date_range.to_params
            expect(params[:d1]).to eq('2021-02-16 13:23:14')
            expect(params[:d2]).to eq('2021-02-17 15:23:14')
          end
        end

        describe :ensure_date_range do
          it 'accepts a DateRange' do
            date_range = DateRange.new(from_time: t1, until_time: t2)
            expect(DateRange.ensure_date_range(date_range)).to be(date_range)
          end

          it 'accepts a range of Dates' do
            d1 = t1.to_date
            d2 = t2.to_date
            date_range = d1..d2
            expected = DateRange.new(from_time: d1, until_time: d2)
            expect(DateRange.ensure_date_range(date_range)).to eq(expected)
          end

          it 'accepts a range of times' do
            time_range = t1..t2
            expected = DateRange.new(from_time: t1, until_time: t2)
            expect(DateRange.ensure_date_range(time_range)).to eq(expected)
          end

          it 'is always in UTC' do
            time_range = t1..t2
            date_range = DateRange.ensure_date_range(time_range)
            expect(date_range.from_time).to eq(t1.getutc)
            expect(date_range.until_time).to eq(t2.getutc)
          end

          it 'rejects things that are not date/time ranges' do
            expect { DateRange.ensure_date_range('1975-1990') }.to raise_error(ArgumentError)
          end
        end
      end
    end
  end
end
