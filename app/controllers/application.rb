# The filters added to this controller will be run for all controllers in the application.
# Likewise will all the methods added be available for all controllers.
class ApplicationController < ActionController::Base
  include AuthFactory
  before_filter :authorize, :except => 'login'
end
