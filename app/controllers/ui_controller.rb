class UiController < ApplicationController
  def index
    @api = params[:api]
  end
end
