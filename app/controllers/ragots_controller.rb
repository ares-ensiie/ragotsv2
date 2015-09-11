require 'oauth2'
require 'json'
class RagotsController < ApplicationController
  before_action :authenticate_oauth2, except: :callback
  helper_method :had_already_liked

  def home
    @ragots = Ragot.all.order(created_at: :desc )
  end

  def new
    if params[:ragot] && params[:ragot].length > 0
      Ragot.create({message: params[:ragot], uid: @user["uid"]})
    end
    redirect_to root_path
  end

  def like
    ragot = Ragot.find(params[:id])
    if ! Like.find_by({ragot: ragot, uid: @user["uid"]})
      Like.create({ragot: ragot, uid: @user["uid"]})
    end
    redirect_to root_path
  end

  def unlike
    ragot = Ragot.find(params[:id])
    if Like.find_by({ragot: ragot, uid: @user["uid"]}).count
      Like.destroy({ragot: ragot, uid: @user["uid"]})
    end
    redirect_to root_path
  end

  def had_already_liked
    return Like.find_by({uid: @user["uid"]}).count > 0
  end

  def callback
    set_oauth
    access_token = @oauth.auth_code.get_token(params[:code], :redirect_uri => callback_url)
    session[:access_token] = access_token.token
    redirect_to root_path
  end

  protected

  def set_oauth
    @oauth = OAuth2::Client.new(OAUTH_CONFIG['APP_ID'], OAUTH_CONFIG['APP_SECRET'], :site => OAUTH_CONFIG['OAUTH_PROVIDER'], :ssl => {:verify => false})
  end

  def authenticate_oauth2
    set_oauth
    if session[:access_token]
      access_token = OAuth2::AccessToken.new(@oauth, session[:access_token])
      begin
        @user = JSON.parse(access_token.get("/api/v1/me.json").body)
        return
      rescue Exception => e
        puts e.message
      end
    end
    redirect_to @oauth.auth_code.authorize_url(:redirect_uri => callback_url)
  end
end
