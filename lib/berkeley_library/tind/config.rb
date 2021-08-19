require 'berkeley_library/util/uris'
require 'berkeley_library/tind/module_info'

require 'tzinfo'

module BerkeleyLibrary
  module TIND
    module Config

      # The environment variable from which to read the TIND API key.
      ENV_TIND_API_KEY = 'LIT_TIND_API_KEY'.freeze

      # The root URL for the TIND installation
      ENV_TIND_BASE_URL = 'LIT_TIND_BASE_URL'.freeze

      DEFAULT_TZID = 'America/Los_Angeles'.freeze
      DEFAULT_USER_AGENT = "#{ModuleInfo::NAME} #{ModuleInfo::VERSION} (#{ModuleInfo::HOMEPAGE})".freeze

      class << self
        include BerkeleyLibrary::Util::URIs

        # Sets the TIND API key.
        # @param value [String] the API key.
        attr_writer :api_key

        # Gets the TIND API key.
        # @return [String, nil] the TIND API key, or `nil` if not set.
        def api_key
          @api_key ||= default_tind_api_key
        end

        def base_uri
          @base_uri ||= default_tind_base_uri
        end

        def base_uri=(value)
          @base_uri = uri_or_nil(value)
        end

        def timezone
          @timezone ||= default_timezone
        end

        def timezone=(value)
          raise ArgumentError, "Not a #{TZInfo::Timezone}" unless value.respond_to?(:utc_to_local)

          @timezone = value
        end

        def user_agent
          @user_agent || DEFAULT_USER_AGENT
        end

        def user_agent=(value)
          raise ArgumentError, 'TIND firewall rules require a user agent' if blank?(value)

          @user_agent = value
        end

        def blank?(v)
          v.nil? || v.to_s.strip.empty?
        end

        private

        def default_timezone
          TZInfo::Timezone.get(Config::DEFAULT_TZID)
        end

        def default_tind_api_key
          ENV[Config::ENV_TIND_API_KEY] || rails_tind_api_key
        end

        def default_tind_base_uri
          return unless (base_url = ENV[Config::ENV_TIND_BASE_URL] || rails_tind_base_uri)

          uri_or_nil(base_url)
        end

        def rails_tind_base_uri
          return unless (rails_config = self.rails_config)
          return unless rails_config.respond_to?(:tind_base_uri)

          rails_config.tind_base_uri
        end

        def rails_tind_api_key
          return unless (rails_config = self.rails_config)
          return unless rails_config.respond_to?(:tind_api_key)

          rails_config.tind_api_key
        end

        def rails_config
          return unless defined?(Rails)
          return unless (app = Rails.application)

          app.config
        end
      end
    end
  end
end
