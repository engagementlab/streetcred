class API::ActionTypesController < ApplicationController
	def index
    @action_types = ActionType.asc(:name)
  end

  def show
  	@action_type = ActionType.find(params[:id])
  end
end
