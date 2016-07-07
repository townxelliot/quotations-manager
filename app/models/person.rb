class Person < ActiveRecord::Base
  has_many :quotations, :dependent => true
  field_stripping_on :name
  
  validates_presence_of :name, :message => "Name is required"
  validates_length_of :name, :maximum => 255, 
    :too_long => "Name is too long"
    
  def remove_quotation_by_id(qid)
    begin
      q = Quotation.find(qid)
      quotations.delete(q) if quotations.include?(q)
    rescue ActiveRecord::RecordNotFound
      return false
    end
  end
  
  # get all categories assigned to this person's quotations
  def assigned_categories
    cats = quotations.collect { |q| q.categories }.flatten
    cat_ids = cats.collect { |c| c.id }.uniq
    Category.find(cat_ids)
  end
end
