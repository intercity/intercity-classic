class StyleguidesController < ApplicationController
  layout "styleguide"

  def index
    render "styleguides/#{params[:category]}"
  end
end
