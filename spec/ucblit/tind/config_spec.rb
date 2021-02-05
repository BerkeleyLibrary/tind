require 'spec_helper'

module UCBLIT
  module TIND
    describe Config do
      let(:env_base_url) { 'tind.example.edu' }

      before(:each) do
        @base_uri_orig = UCBLIT::TIND::Config.instance_variable_get(:@base_uri)
        @base_url_orig = ENV['LIT_TIND_BASE_URL']
        ENV['LIT_TIND_BASE_URL'] = env_base_url
      end

      after(:each) do
        UCBLIT::TIND::Config.instance_variable_set(:@base_uri, @base_uri_orig)
        ENV['LIT_TIND_BASE_URL'] = @base_url_orig
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
          require 'rails'

          url = 'tind-test.example.edu'
          config = OpenStruct.new(tind_base_uri: url)

          app = instance_double(Rails::Application)
          allow(app).to receive(:config).and_return(config)
          allow(Rails).to receive(:application).and_return(app)

          ENV['LIT_TIND_BASE_URL'] = nil
          expect(Config.base_uri).to eq(URI(url))
        end
      end
    end
  end
end
