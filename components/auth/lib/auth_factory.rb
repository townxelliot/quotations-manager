# to make authentication available to all controllers
# put the auth directory into the components directory of the application,
# and include this line:
#   include AuthFactory
# in application.rb inside the class definition
module AuthFactory

  # base class for all authentication classes
  class AuthBase
    include Singleton
    
    # create + set instance variables corresponding to parameters
    def set_config(parameters)
      parameters.each do |k,v|
        self.instance_variable_set("@#{k}".to_sym, v)
      end
    end
    
    # check username and password; override in subclass
    def check_credentials(username, password)
      return false
    end
    
    # allow access to login, logout and check actions by default, 
    # or allow access if session 'logged_in' variable set;
    # override in subclass to do per-path authorization;
    # this default implementation doesn't apply any path-based restrictions,
    # but just generates some path info for the logs
    def authorized?(logged_in, username, controller_name, action_name, id)
      path = "#{controller_name}/#{action_name}"
      path = "#{path}/#{id}" if id
      if logged_in or ["login", "logout", "check"].include?(action_name)
        RAILS_DEFAULT_LOGGER.info "Access granted to #{path}"
        return true
      else
        RAILS_DEFAULT_LOGGER.info "Access DENIED to #{path}"
        return false
      end
    end
  end
  
  # default action to redirect to when user logs out (uses current controller)
  DEFAULT_ACTION = 'index'

  # configure the authenticator for the application
  CONFIG = File.open("#{RAILS_ROOT}/components/auth/auth_config.yml") { |f| YAML::load(f) }

  # class of the authenticator to be used
  KLASS = CONFIG['class']

  # parameters to pass to the authenticator instance
  PARAMS = CONFIG['parameters']

  # return authenticator instance loaded with parameters 
  AUTHENTICATOR = Object.const_get(KLASS).instance
  AUTHENTICATOR.set_config(PARAMS)

  ##### methods this module adds to all controllers

  # render the login page
  def login
    render :file => "#{RAILS_ROOT}/components/auth/login/index.rhtml", :layout => true
  end

  # check user credentials
  def check
    username = @params['login']['username']
    password = @params['login']['password']
    if AUTHENTICATOR.check_credentials(username, password)
      @session['logged_in'] = true
      @session['username'] = username
      flash[:notice] = "Login succeeded"
      if @session['return_to']
        redirect_to_path(session['return_to'])
        @session['return_to'] = nil
      else
        redirect_to :action => DEFAULT_ACTION
      end
    else
      flash[:notice] = "Login failed"
      redirect_to :action => 'login'
    end
  end

  # logout the user
  def logout
    @session['logged_in'] = nil
    @session['username'] = nil
    flash[:notice] = "You are now logged out"
    redirect_to :action => DEFAULT_ACTION
  end

  private
    # attempt to authorize user for this controller/action
    def authorize
      if !(AUTHENTICATOR.authorized?(@session['logged_in'], @session['username'], 
      controller_name, action_name, @params[:id]))
        @session['return_to'] = @request.request_uri
        redirect_to :action => 'login'
        return false
      end
    end
end
