class Api::V1::TasksController < ApplicationController
  before_action :authenticate_with_token!

  def index
    begin
      tasks = current_user.tasks
      render json: { tasks: tasks }, status: 200
    rescue
      head 404
    end
  end
end
