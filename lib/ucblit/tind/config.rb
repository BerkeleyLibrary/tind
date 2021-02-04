require 'uri'

module UCBLIT
  module TIND
    module Config

      def base_uri
        Config::base_uri
      end

      class << self

        ENV_TIND_BASE_URL = 'LIT_TIND_BASE_URL'.freeze

        def base_uri
          @base_uri ||= default_tind_base_uri
        end

        def base_uri=(value)
          @base_uri = uri_or_nil(value)
        end

        private

        def uri_or_nil(url)
          return unless url

          url.is_a?(URI) ? url : URI.parse(url)
        end

        def default_tind_base_uri
          return unless (base_url = ENV[ENV_TIND_BASE_URL] || rails_tind_base_uri)

          uri_or_nil(base_url)
        end

        def rails_tind_base_uri
          return unless (rails_config = self.rails_config)
          return unless rails_config.respond_to?(:uri)

          rails_config.uri
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
