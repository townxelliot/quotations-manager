# The methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def my_textilize(text)
    if text.blank?
      ""
    else
      textilized = RedCloth.new(text, [])
      textilized.to_html(:textile)
    end
  end
end