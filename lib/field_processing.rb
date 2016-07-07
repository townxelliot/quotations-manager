require 'digest/sha1'

module FieldProcessing
  def self.append_features(base)
    super
    base.extend(FieldMethods)
  end
  
  module FieldMethods
    # configuration settings for fields
    @@field_configs = {}
    
    # setup a field's configuration container
    def field_config(fieldname)
      # does field already have a configuration hash?
      field_configured = @@field_configs.has_key?(fieldname)
      
      if !field_configured
        # set up a configuration hash for the field
        @@field_configs[fieldname] = {}
      
        # create the new attribute writer for the field;
        # this calls the manipulation methods before setting the field
        define_method("#{fieldname}=") do |value_in|
          value_in = self.class.strip(fieldname, value_in)
          value_in = self.class.sha1(fieldname, value_in)
          write_attribute(fieldname, value_in)
        end
      end
    end
  
    # strip whitespace from a field value
    def strip(fieldname, value_in)
      value_in = value_in.strip if value_in and self.get_key(fieldname, 'strip')
      value_in
    end
    
    # sha1 hash a field value
    def sha1(fieldname, value_in)
      value_in = Digest::SHA1.hexdigest(value_in) if value_in and self.get_key(fieldname, 'sha1')
      value_in
    end
    
    # returns value of the key for fieldname, false if key doesn't exist
    def get_key(fieldname, key)
      value = @@field_configs.has_key?(fieldname.to_sym)
      value = @@field_configs[fieldname.to_sym][key.to_sym] if value
    end
    
    # set a particular feature on for a set of fields
    def set_config_on(fieldnames, feature)
      fieldnames.each do |fieldname|
        self.field_config(fieldname)
        @@field_configs[fieldname][feature] = true
      end
    end
  
    # FEATURES WHICH CAN BE TURNED ON
  
    # turn whitespace stripping on for one or more fields
    def field_stripping_on(*fieldnames)
      self.set_config_on(fieldnames, :strip)
    end
    
    # turn sha1 hashing on for one or more fields
    def field_sha1_on(*fieldnames)
      self.set_config_on(fieldnames, :sha1)
    end
  end
end