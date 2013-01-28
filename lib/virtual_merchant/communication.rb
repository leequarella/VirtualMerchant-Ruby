module VirtualMerchant
  class Communication
    require 'net/http'
    require "rexml/document"
  
    attr_accessor :xml, :url, :http_referer, :uri
  
    def initialize(data)
      @xml = data[:xml]
      @url = data[:url]
      @uri = URI.parse(@url)
      @http_referer = data[:http_referer]
    end
  
    def send
      http = Net::HTTP.new(@uri.host, @uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      begin
        http.post(uri.request_uri, xml, header).body
      rescue
        false
      end
    end
  
    private
    def header
      if @http_referer
        header = { 'Referer' => @http_referer }
      else
        header = {}
      end
    end
  end
end
