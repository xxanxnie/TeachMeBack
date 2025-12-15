class ExploreController < ApplicationController
  before_action :require_login

  def index
    @loading = true
    @query = params[:q].to_s.strip

    # collect filter params
    selected_roles = Array(params[:role] || params[:roles]).map(&:to_s).reject(&:blank?)
    selected_days  = Array(params[:days]).map(&:to_s).reject(&:blank?)
    selected_cats  = Array(params[:categories]).map(&:to_s).reject(&:blank?)

    if defined?(SkillExchangeRequest)
      # total open requests used to decide which empty message to show
      @total_open_requests = SkillExchangeRequest.where(status: SkillExchangeRequest.statuses[:open]).count
      items = SkillExchangeRequest.includes(:user)
                                  .status_open_only
                                  .where("skill_exchange_requests.created_at >= ?", 180.days.ago)
                                  .order(SkillExchangeRequest.arel_table[:created_at].desc)

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
        items = items.where("teach_category IN (?) OR learn_category IN (?)", selected_cats, selected_cats)
      end

      if selected_days.any?
        days_order = %w[mon tue wed thu fri sat sun]
        selected_day_keys = selected_days.map(&:to_s).map(&:downcase)
        indices = selected_day_keys.map { |d| days_order.index(d) }.compact

        if indices.any?
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

      if @query.present?
        downcased_query = @query.downcase
        intent = nil
        skill_term = downcased_query
        if skill_term.start_with?("learn ")
          intent = :learn
          skill_term = skill_term.sub(/\Alearn\s+/, "")
        elsif skill_term.start_with?("learning ")
          intent = :learn
          skill_term = skill_term.sub(/\Alearning\s+/, "")
        elsif skill_term.start_with?("teach ")
          intent = :teach
          skill_term = skill_term.sub(/\Ateach\s+/, "")
        elsif skill_term.start_with?("teaching ")
          intent = :teach
          skill_term = skill_term.sub(/\Ateaching\s+/, "")
        end

        skill_term = downcased_query if skill_term.blank?

        if items.respond_to?(:left_outer_joins)
          items = items.left_outer_joins(:user)
          if intent == :learn
            sanitized = ActiveRecord::Base.sanitize_sql_like(skill_term)
            like = "%#{sanitized}%"
            items = items.where("LOWER(skill_exchange_requests.learn_skill) LIKE ?", like)
          elsif intent == :teach
            sanitized = ActiveRecord::Base.sanitize_sql_like(skill_term)
            like = "%#{sanitized}%"
            items = items.where("LOWER(skill_exchange_requests.teach_skill) LIKE ?", like)
          else
            sanitized = ActiveRecord::Base.sanitize_sql_like(downcased_query)
            like = "%#{sanitized}%"
            search_sql = <<~SQL.squish
              LOWER(skill_exchange_requests.teach_skill) LIKE :q OR
              LOWER(skill_exchange_requests.learn_skill) LIKE :q OR
              LOWER(skill_exchange_requests.modality) LIKE :q OR
              LOWER(COALESCE(users.name, '')) LIKE :q OR
              LOWER(COALESCE(users.first_name, '')) LIKE :q OR
              LOWER(COALESCE(users.last_name, '')) LIKE :q OR
              LOWER(TRIM(COALESCE(users.first_name, '') || ' ' || COALESCE(users.last_name, ''))) LIKE :q
            SQL
            items = items.where(search_sql, q: like)
          end
        else
          items = Array(items).select do |record|
            base_values = [
              record.modality,
              record.user&.name,
              record.user&.first_name,
              record.user&.last_name,
              [record.user&.first_name, record.user&.last_name].compact.join(" ")
            ].compact
            values = [
              record.teach_skill,
              record.learn_skill
            ].compact
            if intent == :learn
              values = [record.learn_skill].compact
              values.any? { |val| val.to_s.downcase.include?(skill_term) }
            elsif intent == :teach
              values = [record.teach_skill].compact
              values.any? { |val| val.to_s.downcase.include?(skill_term) }
            else
              (values + base_values).any? { |val| val.to_s.downcase.include?(downcased_query) }
            end
          end
        end
      end

      records =
        if items.is_a?(ActiveRecord::Relation)
          items.limit(200).to_a
        else
          Array(items)
        end

      records = records.reject(&:expired?)
      @results = records.first(100)
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

  private

  def require_login
    return if current_user.present?

    flash[:alert] = "Please log in to access explore."
    redirect_to root_path
  end
end
