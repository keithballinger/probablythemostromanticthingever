require "sinatra"
require "./config/app_config"
require "./lib/helpers"
include Helpers

enable :logging, :sessions
use Rack::MethodOverride

get '/' do
  erb :index, layout: !request.xhr?
end

get '/authorize' do
  session[:state] = random_string
  redirect to "https://www.facebook.com/dialog/oauth?client_id=#{APP_CONFIG['fb_key']}&redirect_uri=#{request.url.gsub('authorize', 'open')}&state=#{session[:state]}"
end

get '/open' do
  if params[:state] == session[:state] && params[:code]
    user_id = fb_auth(params[:code])
  end

  session.delete(:state)

  @day = defined?(user_id) ? get_day(user_id) : -1

  erb :open, layout: !request.xhr?
end

