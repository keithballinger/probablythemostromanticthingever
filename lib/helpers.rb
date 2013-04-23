require "./config/app_config"

module Helpers
  def random_string(length=10)
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    string = ""
    1.upto(length) { |i| string << chars[rand(chars.size-1)] }
    string << Time.now.to_i.to_s
    return string
  end

  def external_get(url)
    require 'net/http'
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.is_a?(URI::HTTPS)
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE unless defined?(RACK_ENV) && RACK_ENV == 'production'

    req = Net::HTTP::Get.new(uri.request_uri)

    res = http.request(req)

    return res
  end

  def request_access_token_from_fb_code(code)
    url = "https://graph.facebook.com/oauth/access_token?client_id=#{APP_CONFIG['fb_key']}&redirect_uri=#{request.url}&client_secret=#{APP_CONFIG['fb_secret']}&code=#{params[:code]}"

    res = external_get(url)

    opts = {}
    res.body.split('&').each do |opt|
      o = opt.split('=')
      opts.merge!(o.first => o.last)
    end

    return opts['access_token']
  end

  def request_user_id_from_fb_access_token(token)
    require 'json'
    url = "https://graph.facebook.com/me?access_token=#{token}"
    res = external_get(url)

    json = JSON.parse(res.body)

    return json['id']
  end

  def fb_auth(code)
    access_token = request_access_token_from_fb_code(code)
    user_id = request_user_id_from_fb_access_token(access_token)
    return user_id
  end

  def send_twilio_sms(user_id, day)
    require 'net/http'
    msg = "#{user_id} signed into PTMRTE for day #{day}"
    to = APP_CONFIG['twilio_to']
    from = APP_CONFIG['twilio_from']

    url = "https://api.twilio.com/2010-04-01/Accounts/#{APP_CONFIG['twilio_key']}/SMS/Messages"
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.is_a?(URI::HTTPS)
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE unless defined?(RACK_ENV) && RACK_ENV == 'production'

    req = Net::HTTP::Post.new(uri.request_uri)
    req.basic_auth(APP_CONFIG['twilio_key'], APP_CONFIG['twilio_secret'])
    req.set_form_data('Body' => msg,
                      'To' => to,
                      'From' => from)

    return http.request(req)
  end

  def get_day(user_id)
    require 'redis'
    redis = Redis.new

    if redis.hexists('authed_user_ids', user_id)
      require 'date'
      date = redis.hget('authed_user_ids', user_id)
      if date.nil? || date.empty?
        date = Date.today
        redis.hset('authed_user_ids', user_id, date.to_s)
        day = 0
      else
        day = (Date.today - Date.parse(date)).to_i
      end
      send_twilio_sms(user_id, day)
    end

    return day
  end
end
