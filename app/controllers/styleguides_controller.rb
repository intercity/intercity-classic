class StyleguidesController < ApplicationController
  layout "styleguide"

  def index
    render "styleguides/#{category}"
  end

  private

  def category
    if allowed_category?
      params[:category]
    else
      "buttons"
    end
  end

  def allowed_category?
    template_exists?("styleguides/#{params[:category]}")
  end
end
