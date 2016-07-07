require File.dirname(__FILE__) + '/../test_helper'

class QuotationTest < Test::Unit::TestCase
  fixtures :quotations, :categories, :categories_quotations, :people

  def setup
    @content_string = "Hello world"
    @comment_string = "There must be more to say than that!"
    @bad_category_string = "[[[)>*"
    @new_cat_string = "  %s  %s   " % [@home_cat.name, @religion_cat.name]
  end

  # test operations on fixtures
  def test_retrieve
    q = Quotation.find(2)
    assert_equal "Lots going on.", q.content
  end
  
  # shouldn't lose category if it remains attached to at least one other quotation
  def test_destroy
    assert_destroyable @work_opinion
    assert @work_cat.reload
    assert_equal @work_cat, Category.find(@work_cat.id)
  end
  
  # should lose category if it is only attached to the deleted quotation
  def test_purge
    religion_cat_original_id = @religion_cat.id
    assert_equal 1, @religion_cat.quotations.size
    assert @importance_of_religion.destroy
    # check the religion category has purged properly
    assert_raise(ActiveRecord::RecordNotFound) { Category.find(religion_cat_original_id) }
  end
  
  def test_update
    @work_opinion.content = @content_string
    assert @work_opinion.save
    @work_opinion.reload
    assert_equal @content_string, @work_opinion.content
  end
  
  def test_create
    new_q = Quotation.new
    new_q.content = @content_string
    new_q.recorded_on = Date.today
    new_q.person_id = 1
    new_q.comment = @comment_string
    new_q.categories_string = @new_cat_string
    assert new_q.save
    assert new_q.reload
    assert_equal 2, new_q.categories.size
    assert new_q.categories.include?(@home_cat)
  end

  # test mutation of fixtures
  def test_content_empty
    @work_opinion.content = nil
    assert !@work_opinion.save
  end
  
  def test_recorded_on_empty
    @work_opinion.recorded_on = nil
    assert !@work_opinion.save
  end
  
  def test_recorded_on_in_future
    @work_opinion.recorded_on = Date.today.next
    assert !@work_opinion.save
  end
  
  # if categories_string is set, all previously existing categories should be removed
  def test_reset_categories
    assert @work_opinion.categories_string = @new_cat_string
    assert @work_opinion.reload
    assert_equal 2, @work_opinion.categories.size
    assert @work_opinion.categories.include?(@home_cat)
    assert !@work_opinion.categories.include?(@work_cat)
  end
  
  # if we set categories such that an existing category is removed,
  # category should purge
  def test_category_purged
    religion_cat_original_id = @religion_cat.id
    assert @importance_of_religion.categories_string = @work_cat.name
    assert @importance_of_religion.save
    assert @importance_of_religion.categories.include?(@work_cat)
    assert !@importance_of_religion.categories.include?(@religion_cat)
    assert_raise(ActiveRecord::RecordNotFound) { Category.find(religion_cat_original_id) }
  end
  
  # test relationships between models

  # people
  def test_person_id_not_exists
    @work_opinion.person_id = 999999999999999999999999
    assert !@work_opinion.save
  end
  
  def test_person_empty
    @work_opinion.person = nil
    assert !@work_opinion.save
  end
  
  def test_set_person
    @work_opinion.person = @john
    assert @work_opinion.save
    @work_opinion.reload
    assert_equal 'John', @work_opinion.person.first_name
  end
  
  # categories

  # must assign a category to a quotation
  def test_category_not_assigned
    @work_opinion.categories = []
    assert !@work_opinion.save
  end
  
  def test_categories_attached_ok
    assert_equal 2, @home_hobbies.categories.size
  end
  
  def test_set_categories
    @work_opinion.categories = [@work_cat, @religion_cat]
    assert @work_opinion.save
    @work_opinion.reload
    assert_equal 2, @work_opinion.categories.size
    assert @work_opinion.categories.include?(@work_cat)
  end
  
  def test_add_category_by_string
    assert @work_opinion.set_categories_by_string(@home_cat.name)
    assert @work_opinion.save
    @work_opinion.reload
    assert @work_opinion.categories.include?(@home_cat)
    @work_opinion.reload
  end
  
  # empty string for categories is rejected, as is invalid category string;
  # in both cases, categories aren't changed
  def test_cant_add_invalid_categories_string
    @work_opinion.set_categories_by_string("")
    assert !@work_opinion.save
    @work_opinion.set_categories_by_string(@bad_category_string)
    assert !@work_opinion.save
  end
  
  # add three categories, one of which is already a category for the quotation,
  # one of which is not a category at all;
  # so we should end up with the original number of categories assigned to the 
  # quotation + 2; and a new category in the database as well
  def test_add_multiple_categories_by_string
    total_num_categories = Category.count

    categories_to_add = "%s %s %s" % [@work_cat.name, @religion_cat.name, "popular"]
    
    # check the two categories have been added to the quotation
    assert @work_opinion.set_categories_by_string(categories_to_add)
    assert_equal 3, @work_opinion.categories.size
    
    # check the new category has been added
    assert_equal total_num_categories + 1, Category.count
    assert Category.find_by_name("popular")
  end
  
  def test_remove_category
    @work_opinion.remove_category_by_string(@work_cat.name)
    assert @work_opinion.categories.empty?
  end
  
  def test_cant_remove_unassigned_category
    assert !@work_opinion.remove_category_by_string(@home_cat.name)
  end
end
