class CategoriesController < ApplicationController
  def index
    @category_pages, @categories = paginate('category', :order_by => 'name ASC', 
      :per_page => 20)
  end
  
  def quotations_in
    @category = Category.find(params[:id])
  end
  
  def edit
    if request.post?
      @category = Category.find(params[:id])
      if @category.update_attributes(params[:category])
        flash[:notice] = 'Category was successfully renamed.'
        redirect_to :action => 'index'
      end
    else
      @category = Category.find(params[:id])
    end
  end
  
  def delete
    # TODO: delete category; can only be done if no quotations are attached
  end
end
