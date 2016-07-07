# Authenticate against Rails model class with username and passeword fields
# NB this class is a singleton (inherited from AuthBase)
#
# parameters which can be specified in auth_config.yml:
# model = name of the model class to use; must support a find method
# (i.e. be a subclass of ActiveRecord::Base) (required)
# username_field = name of the field to compare supplied username against (required)
# password_field = name of the field to compare supplied password against (required)
# access_log_field = datetime field to record access datetimes in; 
# set to datetime of login each time the user logs in (optional)
# password_hash = one of "MD5" or "SHA1" (or other hash which has a class in
# the Digest module) (NB case is irrelevant); 
# the hash to apply to the password before comparing against the database (optional)
#
# parameters are set from the config file when the AuthFactory is used to create
# the authenticator instance

class AuthDb < AuthFactory::AuthBase

  # compare user credentials against model
  def check_credentials(username, password)
    u = lookup_user(username, password)
    if u
      log_access(u)
      return true
    else
      return false
    end
  end

  # lookup user via model
  def lookup_user(username, password)
    if @hash_algorithm
      require "digest/#{@hash_algorithm.downcase}"
      password = Object.const_get("Digest").const_get(@hash_algorithm.upcase).hexdigest(password)
    end
    eval("#{@model}.find(:first,
      :conditions => [ '#{@username_field}=? AND #{@password_field}=?', username, password ])") 
  end

  # log user access into model
  def log_access(user)
    if @access_log_field
      eval("user.#{@access_log_field} = Time.now")
      user.save
    end
  end
end
