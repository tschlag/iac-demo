class DiscoveryController < ApplicationController
    def index
      @user = User.where("id = #{params[:id]}").first
      klass = params[:class_name].constantize
      @comment_html = raw(params[:comment]) 
    end
  end