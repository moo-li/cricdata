module Fetch
  def get_response query
dputs "Getting #{query}" # debug
    @attempts ||= 0
    @attempts +=1
    raise StandardError, "Too many redirects" if @attempts > 10

    uri = URI.parse query
dputs uri # debug
    case uri.scheme
    when 'https'
      connection              = Net::HTTP.new(uri.host, uri.port)
      connection.use_ssl      = true
      connection.verify_mode  = OpenSSL::SSL::VERIFY_NONE
      request                 = Net::HTTP::Get.new(uri.request_uri)
      response                = connection.request(request)
    else
      response                = Net::HTTP.get_response(uri)
    end

    case response
    when Net::HTTPSuccess, Net::HTTPNotModified
      @attempts = 0
      return response.body
    when Net::HTTPRedirection
      location = response['location']
dputs 'Redirecting...' # debug
      return get_response(location) # recursion!
    else
      raise StandardError, "Status code #{response.code} received for request #{query}"
    end
  end

  def get_data query
    return Nokogiri::HTML get_response(query)
  end
end
