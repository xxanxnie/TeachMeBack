class MatchController < ApplicationController
   before_action :require_login

  def index
    @loading = true
  end
end
