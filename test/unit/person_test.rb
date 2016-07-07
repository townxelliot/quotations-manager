require File.dirname(__FILE__) + '/../test_helper'

class PersonTest < Test::Unit::TestCase
  fixtures :people, :quotations, :categories

  def setup
  end

  # test fixtures
  def test_create  
    p = Person.new
    p.first_name = 'Burt'
    p.last_name = 'Skink'
    assert p.save
  end
  
  def test_retrieve
    p = Person.find(1)
    assert_equal 'Elliot', p.first_name
    assert_equal 'Smith', p.last_name
  end
  
  def test_update
    @elliot.first_name = 'Gary'
    assert @elliot.save
    @elliot.reload
    assert_equal 'Gary', @elliot.first_name
  end
  
  def test_destroy
    assert @elliot.destroy
  end
  
  # test virtual attributes
  def test_full_name
    assert_equal 'Elliot Smith', @elliot.full_name
  end
  
  # test breaking fixtures
  
  # don't allow first_name or last_name to be empty
  def test_first_name_empty
    assert_reject_empty @elliot, :first_name
  end
  
  def test_last_name_empty
    assert_reject_empty @elliot, :last_name
  end

  # don't allow first_name or last_name to be over 255 characters
  def test_first_name_too_long
    @elliot.first_name = "a" * 256
    assert !@elliot.save
  end

  def test_first_name_too_long
    @elliot.last_name = "a" * 256
    assert !@elliot.save
  end
  
  # names must contain some characters other than whitespace
  def test_names_not_just_whitespace
    assert_reject_whitespace @elliot, :first_name
    assert_reject_whitespace @elliot, :last_name
  end
  
  # names saved into the database should have whitespace stripped
  def test_first_name_whitespace_stripped
    assert_trimmed @elliot, :first_name
  end
  
  def test_last_name_whitespace_stripped
    assert_trimmed @elliot, :last_name
  end
  
  # test relationships with other models
  def test_related_quotations
    assert_equal 2, @elliot.quotations.size
  end
  
  def test_remove_quotation_by_id
    assert @elliot.remove_quotation_by_id(1)
    assert_equal 1, @elliot.quotations.size
    assert_equal "Lots going on.", @elliot.quotations.first.content
  end
  
  # get all the categories assigned to a person's quotations
  def test_related_categories
    cats_to_test = @tony.assigned_categories
    assert_equal 2, cats_to_test.size
    assert cats_to_test.include?(@work_cat)
    assert cats_to_test.include?(@home_cat)
  end
end
