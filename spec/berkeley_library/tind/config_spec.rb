require 'spec_helper'

module BerkeleyLibrary
  module TIND
    describe Config do
      let(:env_base_url) { 'tind.example.edu' }
      let(:env_api_key) { 'not-a-real-api-key' }

      before(:each) do
        @base_uri_orig = Config.instance_variable_get(:@base_uri)
        Config.instance_variable_set(:@base_uri, nil)

        @base_url_orig = ENV['LIT_TIND_BASE_URL']
        ENV['LIT_TIND_BASE_URL'] = env_base_url

        @api_key_orig = Config.instance_variable_get(:@api_key)
        Config.instance_variable_set(:@api_key, nil)

        @api_key_env_orig = ENV['LIT_TIND_API_KEY']
        ENV['LIT_TIND_API_KEY'] = env_api_key
      end

      after(:each) do
        Config.instance_variable_set(:@base_uri, @base_uri_orig)
        ENV['LIT_TIND_BASE_URL'] = @base_url_orig

        Config.api_key = @api_key_orig
        ENV['LIT_TIND_API_KEY'] = @api_key_env_orig
      end

      describe :base_uri do
        it 'returns the base URL from the environment as a URI' do
          expect(Config.base_uri).to eq(URI(env_base_url))
        end

        it 'returns nil if no base URL is set in the environment' do
          ENV['LIT_TIND_BASE_URL'] = nil
          expect(Config.base_uri).to be_nil
        end

        it 'returns a URI from Rails config if present' do
          expect(defined?(Rails)).to be_nil

          Object.send(:const_set, 'Rails', OpenStruct.new)
          Rails.application = OpenStruct.new

          url = 'tind-test.example.edu'
          config = OpenStruct.new(tind_base_uri: url)
          Rails.application.config = config

          ENV['LIT_TIND_BASE_URL'] = nil
          expect(Config.base_uri).to eq(URI(url))
        ensure
          Object.send(:remove_const, 'Rails')
        end
      end

      describe :api_key do
        it 'returns the API key from the environment' do
          expect(Config.api_key).to eq(env_api_key)
        end

        it 'returns nil if no API key is set in the environment' do
          ENV['LIT_TIND_API_KEY'] = nil
          expect(Config.api_key).to be_nil
        end

        it 'returns an API key from the Rails config if present' do
          expect(defined?(Rails)).to be_nil

          Object.send(:const_set, 'Rails', OpenStruct.new)
          Rails.application = OpenStruct.new

          api_key = 'test-api-key'
          config = OpenStruct.new(tind_api_key: api_key)
          Rails.application.config = config

          ENV['LIT_TIND_API_KEY'] = nil
          expect(Config.api_key).to eq(api_key)
        ensure
          Object.send(:remove_const, 'Rails')
        end
      end
    end
  end
end
