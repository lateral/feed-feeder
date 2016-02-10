module RequestHelper
  def authorise!
    creds = Credentials.find_by! url_hash: params[:hash], slug: params[:slug]
    if creds.password_protected?
      error! 'Unauthorised', 403 if request.headers['Authorization'] != creds.basic_auth
    end
    @subscription_key = creds.key
  end

  def api_headers
    { 'Content-Type' => 'application/json', 'Subscription-Key' => @subscription_key }
  end

  def get(url, params = {})
    api_request :get, url, params
  end

  def get_json(url, params = {})
    json_request :get, url, params
  end

  def post(url, params = {})
    api_request :post, url, params
  end

  def post_json(url, params = {})
    json_request :post, url, params
  end

  def api_request(method, url, params = {})
    api_headers.merge!(params: params) if method == :get
    RestClient::Request.execute method: method,
                                url: "#{API_URL}#{url}",
                                payload: params.to_json,
                                headers: api_headers
  rescue RestClient::ExceptionWithResponse => err
    results = JSON.parse(err.response.to_str)
    error! results['message'], err.response.code
  end

  def json_request(method, url, params = {})
    JSON.parse api_request(method, url, params)
  end
end
