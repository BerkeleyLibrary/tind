require 'spec_helper'

module UCBLIT
  module Util
    module ODS
      module XML
        module Style
          describe Family do
            describe :ensure_family do
              it "returns a #{Family} as itself" do
                Family.each do |f|
                  expect(Family.ensure_family(f)).to be(f)
                end
              end

              it 'finds a family by key' do
                Family.each do |f|
                  variants = [
                    f.key.to_s,
                    f.key.to_sym,
                    f.key.to_s.upcase,
                    f.key.to_s.upcase.to_sym,
                    f.key.to_s.downcase,
                    f.key.to_s.downcase.to_sym
                  ]
                  variants.each do |k|
                    expect(Family.ensure_family(k)).to be(f)
                  end
                end
              end

              it 'finds a family by value' do
                Family.each do |f|
                  variants = [
                    f.value.to_s,
                    f.value.to_sym,
                    f.value.to_s.upcase,
                    f.value.to_s.upcase.to_sym,
                    f.value.to_s.downcase,
                    f.value.to_s.downcase.to_sym
                  ]
                  variants.each do |v|
                    expect(Family.ensure_family(v)).to be(f)
                  end
                end
              end

              it 'rejects invalid families' do
                expect { Family.ensure_family(:not_a_family) }.to raise_error(ArgumentError)
              end
            end
          end
        end
      end
    end
  end
end
