module FormHelper
  def validation_errors(object, field)
    return unless object.errors.keys.include?(field)
    "<small>#{object.errors.messages[field].first}</small>".html_safe
  end

  def validation_errors?(object, field)
    object.errors.keys.include?(field)
  end
end
