class BattlesController < ApplicationController
  before_action :set_battle, only: [:show]
  before_action :require_team!

  def show
    render json: {
      name: @battle.name,
      replay: {via: :get, url: battle_faucet_url(@battle)},
      data: @battle.data
    }
  end

  private
    def set_battle
      @battle = Battle.find(params[:id])
      if not @battle.status.eql?('active')
        render nothing: true, status: 404
        return
      end
    end

    def battle_params
      params.require(:battle).permit(:name)
    end
end
