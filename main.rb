class DiscoveryController < ApplicationController
    def index
      # HIGH SEVERITY: Insecure Direct Object Reference / SQLi
      # Using 'params' directly in a where clause string bypasses built-in sanitization.
      @user = User.where("id = #{params[:id]}").first # SAST Trigger: rails_sql_injection
  
      # CRITICAL SEVERITY: Remote Code Execution (Unsafe Reflection)
      # Constantizing a string from a user parameter allows an attacker to 
      # instantiate or call any class in the application.
      klass = params[:class_name].constantize # SAST Trigger: unsafe_reflection
  
      # HIGH SEVERITY: Cross-Site Scripting (XSS)
      # The 'raw' helper tells Rails not to escape the content, leading to 
      # malicious script execution in the user's browser.
      @comment_html = raw(params[:comment]) # SAST Trigger: rails_xss
    end
  end