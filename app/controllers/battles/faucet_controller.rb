class Battles::FaucetController < ApplicationController
  before_action :require_team!

  def index
    Battle.find(params[:battle_id])
    Process.spawn(".gems/bin/bundle exec rails r lib/replay_battle.rb #{params[:battle_id]} #{current_team.token}")
    render nothing: true, status: 202
  end

  def create
    puts params[:payload]
  end
end
