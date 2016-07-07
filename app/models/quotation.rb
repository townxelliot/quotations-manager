class Quotation < ActiveRecord::Base  
  has_and_belongs_to_many :categories
  belongs_to :person

  validates_presence_of :content, :message => "Please enter some content"
  validates_presence_of :recorded_on,
    :message => "Please select the date when the quotation was recorded"
  validates_presence_of :person, :message => "Please assign the quotation to a person"
  
  def validate
    if recorded_on && recorded_on > Date.today
      errors.add(:recorded_on, "Quotation must have been recorded in the past")
    end
    if categories.size < 1
      errors.add(:categories_string, "Please specify at least one valid category for this quotation")
    end
  end
  
  # this should remove all categories and reset them for this quotation
  def categories_string=(cat_names)
    set_categories_by_string(cat_names) 
  end
  
  def categories_string
    categories.collect {|c| c.name}.join(" ")
  end

  # add one or more categories passed in as a string with spaces between items;
  # will also add new categories to the database; and try to purge categories
  # previously attached to the quotation which have been removed from the string
  def set_categories_by_string(cat_names)
    old_categories = categories.clone
    categories.clear
    cat_names_array = cat_names.split(" ")
    cat_names_array.each do |cat_name|
      cat = Category.find_by_name(cat_name) || Category.create({ :name => cat_name })
      categories << cat if cat.valid? and !(categories.include?(cat))
    end
    old_categories.each { |old_cat| old_cat.purge if !(categories.include?(old_cat)) }
  end
  
  # remove a specified category
  def remove_category_by_string(cat_name)
    begin
      cat = Category.find_by_name(cat_name)
      categories.delete(cat) if categories.include?(cat)
      # purge the category from the database if no quotations remain attached
      cat.purge
    rescue ActiveRecord::RecordNotFound
      return false
    end
  end
  
  protected
  
  # after initialising, save a copy of the categories associated with the quotation;
  # this is used to clear categories after a quotation is deleted;
  # because after_destroy for quotation occurs after links to categories have
  # been removed
  def after_initialize
    @categories_copy = categories.clone
  end
  
  # purge the copy of the categories for a quotation
  def before_destroy
    @categories_copy.each do |cc|
      cc.purge
    end
  end
end
