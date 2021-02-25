# ------------------------------------------------------------
# Simplecov

require 'colorize'
require 'simplecov' if ENV['COVERAGE']

# ------------------------------------------------------------
# RSpec

require 'webmock/rspec'

RSpec.configure do |config|
  config.color = true
  config.tty = true
  config.formatter = :documentation
  config.before(:each) { WebMock.disable_net_connect!(allow_localhost: true) }
  config.after(:each) { WebMock.allow_net_connect! }
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups
end

# ------------------------------------------------------------
# Code under test

require 'ucblit/tind'

FileUtils.mkdir_p('log')
UCBLIT::TIND.logger = UCBLIT::Logging::Loggers.new_readable_logger('log/test.log')

# ------------------------------------------------------------
# Helper methods

# TODO: replace w/custom matcher

module MARC
  class Record
    HEADER_RE = /^(?<tag>[0-9]{3})(?<ind1>[0-9a-z_])(?<ind2>[0-9a-z_])(?<subfield_code>[0-9a-z])/.freeze

    class << self
      def decompose_header(tind_col_header)
        raise ArgumentError, "Not a table column header: #{tind_col_header.inspect}" unless (md = HEADER_RE.match(tind_col_header))

        tag = md['tag']
        ind1 = md['ind1'] == '_' ? ' ' : md['ind1']
        ind2 = md['ind2'] == '_' ? ' ' : md['ind2']
        subfield_code = md['subfield_code']

        [tag, ind1, ind2, subfield_code]
      end
    end

    def values_for(tind_col_header)
      tag, ind1, ind2, subfield_code = MARC::Record.decompose_header(tind_col_header)
      [].tap do |values|
        each_by_tag(tag) do |df|
          next unless df.indicator1 == ind1
          next unless df.indicator2 == ind2

          df.subfields.each do |sf|
            next unless sf.code == subfield_code

            values << sf.value unless sf.value.to_s == ''
          end
        end
      end
    end
  end
end
