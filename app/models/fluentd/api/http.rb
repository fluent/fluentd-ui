require "httpclient"
require "addressable/uri"

class Fluentd
  class Api
    class Http
      def initialize(endpoint)
        @endpoint = Addressable::URI.parse(endpoint)
      end

      def config
        request("/api/config.json")
      end

      private

      def request(path)
        uri = @endpoint.dup
        uri.path = path
        res = HTTPClient.get(uri)
        JSON.parse res.body
      end
    end
  end
end

