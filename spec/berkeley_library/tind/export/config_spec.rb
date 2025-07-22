require 'spec_helper'

module BerkeleyLibrary
  module TIND
    module Export
      describe Config do
        let(:env_vars) do
          %w[
            ODS_FONT_SIZE_DEFAULT
            ODS_FORMAT_DIGITS_DEFAULT
            ODS_HEIGHT_INCREMENT_DEFAULT_POINTS
            ODS_LINE_HEIGHT_DEFAULT_EM
            ODS_MAX_COLUMN_WIDTH_INCHES
            ODS_WIDTH_INCREMENT_DEFAULT_INCHES
          ]
        end

        let(:attrs) do
          %i[
            font_size_pt
            format_digits
            h_incr_pt
            line_height_em
            max_col_width_in
            w_incr_in
          ]
        end

        let(:inst_vars) { attrs.map { |a| "@#{a}".to_sym } }

        before(:each) do
          @env_orig = {}
          env_vars.each do |v|
            @env_orig[v] = ENV.fetch(v, nil)
            ENV[v] = nil
          end
          @inst_orig = {}
          inst_vars.each do |v|
            if Config.instance_variable_defined?(v)
              @inst_orig[v] = Config.instance_variable_get(v)
              Config.remove_instance_variable(v)
            end
          end
        end

        after(:each) do
          @env_orig.each do |k, v|
            ENV[k] = v
          end
          @inst_orig.each do |k, v|
            Config.instance_variable_set(k, v)
          end
        end

        describe 'defaults' do
          it 'returns sensible default values' do
            expected = {
              font_size_pt: Config::FONT_SIZE_DEFAULT,
              max_col_width_in: Config::MAX_COLUMN_WIDTH_INCHES,
              w_incr_in: Config::WIDTH_INCREMENT_DEFAULT_INCHES,
              h_incr_pt: Config::HEIGHT_INCREMENT_DEFAULT_POINTS,
              line_height_em: Config::LINE_HEIGHT_DEFAULT_EM,
              format_digits: Config::FORMAT_DIGITS_DEFAULT
            }
            expected.each do |attr, value|
              expect(Config.send(attr)).to eq(value)
            end
          end
        end

        describe 'ENV' do
          it 'can be configured from the environment' do
            env_vars_by_attr = {
              font_size_pt: 'ODS_FONT_SIZE_DEFAULT',
              max_col_width_in: 'ODS_MAX_COLUMN_WIDTH_INCHES',
              w_incr_in: 'ODS_WIDTH_INCREMENT_DEFAULT_INCHES',
              h_incr_pt: 'ODS_HEIGHT_INCREMENT_DEFAULT_POINTS',
              line_height_em: 'ODS_LINE_HEIGHT_DEFAULT_EM',
              format_digits: 'ODS_FORMAT_DIGITS_DEFAULT'
            }

            expected = env_vars_by_attr.to_h do |attr, var|
              value = 2 * Config.send(attr)
              ENV[var] = value.to_s
              [attr, value]
            end

            inst_vars.each do |v|
              Config.remove_instance_variable(v) if Config.instance_variable_defined?(v)
            end

            expected.each do |attr, value|
              expect(Config.send(attr)).to eq(value)
            end
          end
        end

        describe 'setters' do
          let(:attr_nonint) { attrs - [:format_digits] }

          it 'set the attributes' do
            attrs.each do |attr|
              value = 2 * Config.send(attr)
              Config.send("#{attr}=", value)
              expect(Config.send(attr)).to eq(value)
            end
          end

          it 'accepts integers' do
            attrs.each do |attr|
              value = (2 * Config.send(attr)).ceil
              Config.send("#{attr}=", value)
              expect(Config.send(attr)).to eq(value)
            end
          end

          it 'accepts integers as strings' do
            attrs.each do |attr|
              value = (2 * Config.send(attr)).ceil
              Config.send("#{attr}=", value.to_s)
              expect(Config.send(attr)).to eq(value)
            end
          end

          it 'rejects non-numeric values' do
            attrs.each do |attr|
              value = Config.send(attr)
              expect { Config.send("#{attr}=", 'not a number') }.to raise_error(ArgumentError)
              expect(Config.send(attr)).to eq(value)
            end
          end

          it 'rejects negative values' do
            attrs.each do |attr|
              value = Config.send(attr)
              expect { Config.send("#{attr}=", -value) }.to raise_error(ArgumentError)
              expect(Config.send(attr)).to eq(value)
            end
          end

          it 'rejects zero' do
            attrs.each do |attr|
              value = Config.send(attr)
              expect { Config.send("#{attr}=", 0) }.to raise_error(ArgumentError)
              expect(Config.send(attr)).to eq(value)
            end
          end

          describe :format_digits do
            it 'rejects non-integer numeric values' do
              value = Config.format_digits
              [2.3, '3/5'.to_r].each do |bad_value|
                expect { Config.format_digits = bad_value }.to raise_error(ArgumentError)
              end
              expect(Config.format_digits).to eq(value)
            end

            it 'accepts hex strings' do
              Config.format_digits = '0xba0bab'
              expect(Config.format_digits).to eq(12_192_683)
            end

            it 'accepts octal strings' do
              Config.format_digits = '0123'
              expect(Config.format_digits).to eq(83)
            end
          end

          describe 'non-integer attributes' do
            it 'accepts rationals' do
              attr_nonint.each do |attr|
                value = (2 * Config.send(attr)).to_r
                Config.send("#{attr}=", value)
                expect(Config.send(attr)).to eq(value)
              end
            end

            it 'accepts floats' do
              attr_nonint.each do |attr|
                value = (2 * Config.send(attr)).to_f
                Config.send("#{attr}=", value)
                expect(Config.send(attr)).to eq(value)
              end
            end

            it 'accepts rationals as strings' do
              attr_nonint.each do |attr|
                value = (2 * Config.send(attr)).to_r
                Config.send("#{attr}=", value.to_s)
                expect(Config.send(attr)).to eq(value)
              end
            end

            it 'accepts floats as strings' do
              attr_nonint.each do |attr|
                value = (2 * Config.send(attr)).to_f
                Config.send("#{attr}=", value.to_s)
                expect(Config.send(attr)).to eq(value)
              end
            end
          end
        end
      end
    end
  end
end
