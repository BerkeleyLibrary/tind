require 'spec_helper'

module UCBLIT
  module TIND
    describe API do
      let(:base_uri) { 'https://tind.example.org/' }

      before(:each) do
        @base_uri_orig = UCBLIT::TIND::Config.instance_variable_get(:@base_uri)
        UCBLIT::TIND::Config.base_uri = base_uri
        @logger_orig = UCBLIT::TIND.logger
      end

      after(:each) do
        UCBLIT::TIND::Config.instance_variable_set(:@base_uri, @base_uri_orig)
        UCBLIT::TIND.logger = @logger_orig
      end

      describe :get do
        # TODO: make real body streaming work
        xit "logs an error if the body can't be copied" do
          expected_msg = 'help I am trapped in a fortune cookie factory'
          body = instance_double(HTTP::Response::Body)
          expect(body).to receive(:each).and_raise(IOError, expected_msg)

          instance_double(HTTP::Response).tap do |response|
            status = HTTP::Response::Status.new(200)
            allow(response).to receive(:status).and_return(status)
            allow(response).to receive(:body).and_return(body)
            allow_any_instance_of(HTTP::Client).to receive(:get).and_return(response)
          end

          logdev = StringIO.new
          UCBLIT::TIND.logger = Logger.new(logdev)

          result = StringIO.new
          API.get('some-endpoint') { |b| IO.copy_stream(b, result) }
          expect(result.string).to be_empty
          expect(logdev.string).to include(expected_msg)
        end
      end
    end
  end
end
