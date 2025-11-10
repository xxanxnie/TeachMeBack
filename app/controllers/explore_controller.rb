class ExploreController < ApplicationController
  before_action :require_login

  def index
    @loading = true

    # collect filter params (all come from GET)
    selected_roles = Array(params[:role]).reject(&:blank?)       # e.g. ["student","instructor"]
    selected_days  = Array(params[:days]).reject(&:blank?)       # e.g. ["mon","tues","weekend"]
    selected_cats  = Array(params[:categories]).reject(&:blank?) # e.g. ["music_art","tech_academics"]

    # safe default: empty ActiveRecord::Relation if model exists, else empty array
    if defined?(SkillExchangeRequest)
      items = SkillExchangeRequest.all

      # filter by user role if association exists (assumes SkillExchangeRequest belongs_to :requester or similar)
      if selected_roles.any?
        if SkillExchangeRequest.reflect_on_association(:requester)
          items = items.joins(:requester).where(users: { role: selected_roles })
        elsif SkillExchangeRequest.column_names.include?('role')
          items = items.where(role: selected_roles)
        end
      end

      # filter by category if model has a category column
      if selected_cats.any? && SkillExchangeRequest.column_names.include?('category')
        items = items.where(category: selected_cats)
      end

      # filter by available days if model stores days in an array column named 'available_days' (Postgres)
      if selected_days.any? && SkillExchangeRequest.column_names.include?('available_days')
        # uses Postgres array overlap operator; fallback to simple ILIKE matching if array column not present
        begin
          items = items.where("available_days && ARRAY[?]::varchar[]", selected_days)
        rescue ActiveRecord::StatementInvalid
          # fallback: match any selected day substring in a text column
          day_clauses = selected_days.map { |d| "available_days ILIKE ?" }.join(" OR ")
          items = items.where([day_clauses, *selected_days.map { |d| "%#{d}%" }])
        end
      end

      @results = items.limit(100)
    else
      @results = []
    end

    # keep view compatibility: the view uses @skill_requests
    @skill_requests = @results

    @filters = {
      roles: selected_roles,
      days: selected_days,
      categories: selected_cats
    }
    @loading = false
  end
end
