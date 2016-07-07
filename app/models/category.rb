class Category < ActiveRecord::Base
  has_and_belongs_to_many :quotations
  field_stripping_on :name

  validates_presence_of :name, :message => "Please enter a name for this category"
  validates_length_of :name, :maximum => 255, :too_long => "Category name is too long"
  validates_format_of :name, :with => /^[\w\d]+[\w\d\-\_\#\.@\?;:]+$/, 
    :message => 'Tag name is invalid; valid tag names consist of word characters (a-z), 
    digits, or any of the following: - _ # @ . ? ; : (no spaces are allowed)'
  validates_uniqueness_of :name, :message => "Name already in use"
  
  def purge
    self.destroy if self.quotations.empty?
  end
  
  # remove a quotation by its ID; once removed, check to see whether the
  # category is required (i.e. it is still attached to a quotation)
  def remove_quotation_by_id(id)
    q = Quotation.find_by_name(id)
    quotations.delete(q) if quotations.include?(q)
    self.purge
  end
  
  protected
  def before_destroy
    raise Exception, "Cannot destroy category with attached equations", caller if self.quotations.size > 0
  end
end
