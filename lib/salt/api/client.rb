require 'net/http'
require 'yaml'

module Salt
  module Api
    module Client
      def client
        Net::HTTP.new(hostname, 8000).tap do |client|
          client.use_ssl = true
          # TODO: Allow specifying CA and such
          client.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
      end

      def login(user, password)
        req = Net::HTTP::Post.new("/login")
        req.set_form_data({
          'eauth' => 'pam',
          'username' => user,
          'password' => password
        })
        req['Accept'] = "application/x-yaml"
        resp = client.request(req)
        raise "Login failed" unless resp.kind_of? Net::HTTPSuccess
        parsed_resp = YAML.load(resp.body)["return"]
        raise "Multiple results? (#{parsed_resp.inspect})" if parsed_resp.length > 1
        parsed_resp.first
      end

      def token
        @token ||= login(username, password)["token"]
      end
    end
  end
end