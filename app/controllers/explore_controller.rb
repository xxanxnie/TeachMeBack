class ExploreController < ApplicationController
  before_action :require_login

  def index
    @loading = true

    # collect filter params
    selected_roles = Array(params[:role] || params[:roles]).map(&:to_s).reject(&:blank?)
    selected_days  = Array(params[:days]).map(&:to_s).reject(&:blank?)
    selected_cats  = Array(params[:categories]).map(&:to_s).reject(&:blank?)

    if defined?(SkillExchangeRequest)
      # total open requests used to decide which empty message to show
      @total_open_requests = SkillExchangeRequest.where(status: SkillExchangeRequest.statuses[:open]).count
      items = SkillExchangeRequest.where(status: SkillExchangeRequest.statuses[:open])

      # CATEGORY + ROLE logic:
      # - student -> match teach_category
      # - instructor -> match learn_category
      if selected_roles.any?
        conds = []
        if selected_roles.include?("student")
          if selected_cats.any?
            conds << SkillExchangeRequest.arel_table[:teach_category].in(selected_cats)
          else
          end
        end

        if selected_roles.include?("instructor")
          if selected_cats.any?
            conds << SkillExchangeRequest.arel_table[:learn_category].in(selected_cats)
          else
          end
        end

        if conds.any?
          combined = conds.reduce { |a, b| a.or(b) }
          items = items.where(combined)
        end
      elsif selected_cats.any?
        # no role picked: match either side
        items = items.where("teach_category IN (?) OR learn_category IN (?)", selected_cats, selected_cats)
      end

      # DAYS filtering
      if selected_days.any?
        days_order = %w[mon tue wed thu fri sat sun]
        selected_day_keys = selected_days.map(&:to_s).map(&:downcase)
        indices = selected_day_keys.map { |d| days_order.index(d) }.compact

        if indices.any?
          # try common column names in order of preference
          if SkillExchangeRequest.column_names.include?("availability_mask")
            masks = indices.map { |i| 1 << i }
            clause = masks.map { "availability_mask & ? > 0" }.join(" OR ")
            items = items.where([clause, *masks])
          elsif SkillExchangeRequest.column_names.include?("availability_days")
            items = items.where("availability_days && ARRAY[?]::varchar[]", selected_days.map(&:downcase))
          elsif SkillExchangeRequest.column_names.include?("available_days")
            items = items.where("available_days && ARRAY[?]::varchar[]", selected_days.map(&:downcase))
          else
            items = items.select do |r|
              avail = Array(r.availability_days).map(&:to_s).map(&:downcase)
              (avail & selected_days.map(&:to_s).map(&:downcase)).any? ||
                (avail & indices.map(&:to_s)).any?
            end
          end
        end
      end

      @results = items.respond_to?(:limit) ? items.limit(100) : items.first(100)
    else
      @results = []
    end

    @skill_requests = @results

    @filters = {
      roles: selected_roles,
      days: selected_days,
      categories: selected_cats
    }
    @loading = false
  end
end
