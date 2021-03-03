require 'ucblit/util/uris'
require 'tzinfo'

module UCBLIT
  module TIND
    module Config

      ENV_TIND_BASE_URL = 'LIT_TIND_BASE_URL'.freeze
      DEFAULT_TZID = 'America/Los_Angeles'.freeze

      def base_uri
        Config.base_uri
      end

      class << self
        include UCBLIT::Util::URIs

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

        private

        def default_timezone
          TZInfo::Timezone.get(Config::DEFAULT_TZID)
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

        def rails_config
          return unless defined?(Rails)
          return unless (app = Rails.application)

          app.config
        end
      end
    end
  end
end
