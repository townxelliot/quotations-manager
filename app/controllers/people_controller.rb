class PeopleController < ApplicationController
  def index
    list
    render :action => 'list'
  end
  
  def list
    @person_pages, @people = paginate :person, :per_page => 10, 
    :order_by => 'name ASC'
  end
  
  def show
    prepare(params[:id], params[:category_id], params[:page], params[:sort_order])
    @new_quotation_requested = false
  end
  
  # pull all the model objects together
  def prepare(person_id, category_id, page, sort_order)
    # work out the sort order
    sort_order ? @sort_order = sort_order : @sort_order = "ASC"
    @sort_order = "ASC" if !(["ASC", "DESC"].include?(@sort_order))
    
    # paging stuff
    page_size = 5
    page = 1 if page.nil?
    @page = page.to_i
    offset = (@page-1) * page_size
    
    # get the person
    @person = Person.find(person_id)
    
    # sorted array of categories attached to this person
    @sorted_categories = @person.assigned_categories.sort { |a,b| a.name <=> b.name }
    
    # get all quotations for the person
    @quotations = Quotation.find(:all, :conditions => ['person_id = ?', person_id], 
      :order => "recorded_on %s" % @sort_order)
    
    # if a category ID was passed in, filter the quotations
    if category_id != nil
      @category = Category.find(category_id)
      @quotations = @quotations.delete_if { |q| !q.categories.include?(@category) }
      @category_id = @category.id
    else
      @category_id = nil
    end
    
    # create paginator with the full set of (possibly filtered) quotations
    @quotation_pages = Paginator.new self, @quotations.size, page_size, page
    
    # get the slice of the @quotations array for the current page
    @quotations = @quotations[offset, page_size]
    
    # get all the categories, sorted by name (for creating the categories picker)
    @all_categories = Category.find(:all, :order => 'name ASC')
  end
  
  def show_with_new_q_form
    prepare(params[:id], params[:category_id], params[:page], params[:sort_order])
    @new_quotation_requested = true
    @quotation = Quotation.new
    @quotation.person_id = @person.id
    render :action => 'show'
  end
  
  def show_with_edit_q_form
    prepare(params[:id], params[:category_id], params[:page], params[:sort_order])
    @edit_quotation_requested = true
    @quotation = Quotation.find(params[:quotation_id])
    render :action => 'show'
  end
  
  def edit
    @person = Person.find(params[:id])
    if request.post? and @person.update_attributes(params[:person])
      flash[:notice] = 'Person was successfully updated.'
      redirect_to :action => 'show', :id => @person
    else
      render :action => 'edit'
    end
  end
  
  def new
    if request.post?
      @person = Person.new(params[:person])
      if @person.save
        flash[:notice] = 'Person was successfully created.'
        redirect_to :action => 'show', :id => @person
      else
        render :action => 'new'
      end
    else
      @person = Person.new
      render :action => 'new'
    end
  end
  
  def delete
    Person.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def new_quotation
    if request.post?
      @quotation = Quotation.new(params[:quotation])
      if @quotation.save
        flash[:notice] = 'Quotation was successfully created.'
        redirect_to :action => 'show', :id => @quotation.person
      else
        @new_quotation_requested = true
        prepare(@quotation.person.id, params[:category_id], params[:page], params[:sort_order])
        render :action => 'show'
      end
    end
  end
  
  def edit_quotation
    if request.post?
      @quotation = Quotation.find(params[:quotation][:id])
      if @quotation.update_attributes(params[:quotation])
        flash[:notice] = 'Quotation was successfully updated.'
        redirect_to :action => 'show', :id => @quotation.person
      else
        @edit_quotation_requested = true
        prepare(@quotation.person.id, params[:category_id], params[:page], params[:sort_order])
        render :action => 'show'
      end
    end
  end
  
  def delete_quotation
    Quotation.find(params[:quotation_id]).destroy
    redirect_to :action => 'show', :id => params[:id], 
      :category_id => params[:category_id], :page => params[:page]
  end
end
