require File.dirname(__FILE__) + '/../test_helper'

class CategoryTest < Test::Unit::TestCase
  fixtures :quotations, :categories, :categories_quotations

  def setup
    @name_string = 'play'
    
    # these symbols are valid in a name
    @valid_symbols = ['-','_','#','.','@','?',':',';']
  end

  # test operations on fixtures
  def test_retrieve
    c = Category.find(1)
    assert_equal 'work', c.name
  end
  
  def test_destroy
    assert_destroyable @work_cat
  end
  
  def test_wont_purge_if_has_quotations
    religion_cat_id = @religion_cat.id
    @religion_cat.purge
    @religion_cat.reload
    assert_nothing_raised(ActiveRecord::RecordNotFound) { Category.find(religion_cat_id) }
  end
  
  def test_wont_delete_if_has_quotations
    assert_raise(Exception) { @religion_cat.destroy }
  end
  
  def test_update
    @work_cat.name = @name_string
    assert @work_cat.save
    @work_cat.reload
    assert_equal @name_string, @work_cat.name
  end
  
  def test_create
    new_c = Category.new
    new_c.name = 'play'
    assert new_c.save
  end
  
  # if a category has no associated quotations, remove it
  def test_purge
    religion_cat_id = @religion_cat.id
    assert_equal 2, religion_cat_id
    assert_equal @religion_cat, Category.find(religion_cat_id)
    
    # should purge the category when the next line is executed, as 
    # the category is no longer associated with any quotations
    assert @importance_of_religion.remove_category_by_string(@religion_cat.name)
    
    # should be purged by now
    assert_raise(ActiveRecord::RecordNotFound) { Category.find(religion_cat_id) }
  end

  # test mutation of fixtures
  def test_name_empty
    @work_cat.name = nil
    assert !@work_cat.save
  end
  
  def test_name_too_long
    @work_cat.name = "a" * 256
    assert !@work_cat.save
  end
  
  def test_name_bad_characters
    puts "\nTesting for bad characters as category names"
    [' ', "\'", "\"", '$', '&', '*', '(', ')', '+', '=', ',', '`', 
    '/', "\\", '!', '£', '%', '^', '[', ']', '{', '}', '~', '|', '¬'].each do |c|
      @work_cat.name = c
      puts "Testing character %s" % c
      assert !@work_cat.save
    end
  end
  
  def test_name_ok_characters
    puts "\nTesting names made only of symbols"
    @valid_symbols << @valid_symbols.join
    @valid_symbols.each do |c|
      @work_cat.name = c
      puts "Testing symbol only name %s" % c
      assert !@work_cat.save
    end
  end
  
  def test_duplicate_name
    @dup_cat = Category.new
    existing_name = @work_cat.name
    @dup_cat.name = existing_name
    assert !@dup_cat.save
  end
  
  def test_name_whitespace_stripped
    @work_cat.name = "       work     "
    assert @work_cat.save
    @work_cat.reload
    assert_equal 'work', @work_cat.name
  end
  
  # test relationships between models

  # quotations
  # NB we don't want methods to add quotations to a category:
  # we just add categories to quotations
  def test_quotations_set
    assert_equal 3, @work_cat.quotations.size
  end
  
  # if we delete a category, the quotation associated with it should stay in the database
  def test_removing_category_doesnt_remove_quotations
    assert @work_cat.destroy
    @work_opinion.reload
    assert_equal "An honest opinion.", @work_opinion.comment
    assert !@work_opinion.categories.include?(@work_cat)
    assert !@work_opinion.valid?
  end
end
