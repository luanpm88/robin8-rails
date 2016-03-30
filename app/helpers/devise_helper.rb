module DeviseHelper
  def devise_error_messages!
    if flash[:notice].present?
      return "<span style='color: green'>#{flash[:notice]}</span>".html_safe
    end

    if flash[:alert].present?
      return "<span style='color: red'>#{flash[:alert]}</span>".html_safe
    end
  end
end