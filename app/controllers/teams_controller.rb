class TeamsController < ApplicationController
  before_action :require_team!, only: [:show, :update]

  def show
    render json: current_team
  end

  def create
    @team = Team.new
    @team.name = team_params[:name]
    @team.url = team_params[:url]
    @team.token = SecureRandom.uuid

    if @team.save
      render json: @team.to_json(only: :token), status: :created
    else
      render json: @team.errors, status: :unprocessable_entity
    end
  end

  def update
    team = current_team
    if team.update(team_params)
      render json: team.to_json(only: [:name, :url, :token])
    else
      render json: team.errors, status: :unprocessable_entity
    end
  end

  private
    def team_params
      params.permit(:name, :url)
    end
end
