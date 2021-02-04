require 'spec_helper'
require 'ucblit/util/paths'

module UCBLIT::Util
  describe Paths do
    describe :clean do
      it 'returns nil for nil' do
        expect(Paths.clean(nil)).to be_nil
      end

      it 'returns the shortest equivalent path' do
        orig_to_expected = {
          # Already clean
          '' => '.',
          'abc' => 'abc',
          'abc/def' => 'abc/def',
          'a/b/c' => 'a/b/c',
          '.' => '.',
          '..' => '..',
          '../..' => '../..',
          '../../abc' => '../../abc',
          '/abc' => '/abc',
          '/' => '/',

          # Remove trailing slash
          'abc/' => 'abc',
          'abc/def/' => 'abc/def',
          'a/b/c/' => 'a/b/c',
          './' => '.',
          '../' => '..',
          '../../' => '../..',
          '/abc/' => '/abc',

          # Remove doubled slash
          'abc//def//ghi' => 'abc/def/ghi',
          '//abc' => '/abc',
          '///abc' => '/abc',
          '//abc//' => '/abc',
          'abc//' => 'abc',

          # Remove . elements
          'abc/./def' => 'abc/def',
          '/./abc/def' => '/abc/def',
          'abc/.' => 'abc',

          # Remove .. elements
          'abc/def/ghi/../jkl' => 'abc/def/jkl',
          'abc/def/../ghi/../jkl' => 'abc/jkl',
          'abc/def/..' => 'abc',
          'abc/def/../..' => '.',
          '/abc/def/../..' => '/',
          'abc/def/../../..' => '..',
          '/abc/def/../../..' => '/',
          'abc/def/../../../ghi/jkl/../../../mno' => '../../mno',

          # Combinations
          'abc/./../def' => 'def',
          'abc//./../def' => 'def',
          'abc/../../././../def' => '../../def'
        }

        aggregate_failures 'clean' do
          orig_to_expected.each do |orig, expected|
            expect(actual = Paths.clean(orig)).to eq(expected), "Expected #{expected.inspect} for #{orig.inspect}, got #{actual.inspect}"
          end
        end
      end
    end
  end
end
