# app/models/skill_exchange_request.rb
class SkillExchangeRequest < ApplicationRecord
    belongs_to :user
  
    enum :status,     { open: 0, matched: 1, closed: 2 },        prefix: true
    enum :teach_level, { beginner: 1, intermediate: 2, advanced: 3 }, prefix: true
    enum :learn_level, { beginner: 1, intermediate: 2, advanced: 3 }, prefix: true
  
    DAYS = %w[Sun Mon Tue Wed Thu Fri Sat].freeze
  
    # ---------- REQUIREMENTS (everything required except notes & learning_goal) ----------
    validates :teach_skill, :learn_skill,
              :teach_level, :learn_level,
              :offer_hours, :modality,
              :expires_after_days,
              presence: true
  
    # availability is a bitmask, ensure at least one day is selected
    validate  :availability_days_must_be_selected
  
    # ---------- Constraints ----------
    validates :offer_hours,
              numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 40 }
  
    validates :expires_after_days,
              numericality: { only_integer: true, greater_than_or_equal_to: 7, less_than_or_equal_to: 180 }
  
    validates :modality, inclusion: { in: %w[in_person remote hybrid] }
  
    # Optional
    validates :learning_goal, length: { maximum: 500 }, allow_blank: true
  
    # ---------- Normalization----------
    before_validation do
      self.teach_skill = teach_skill.to_s.strip
      self.learn_skill = learn_skill.to_s.strip
    end
  
    # ---------- Availability helpers ----------
    def availability_days
      DAYS.each_index.select { |i| (availability_mask.to_i & (1 << i)) != 0 }
    end
  
    def availability_days=(indices)
      indices = Array(indices).map(&:to_i).uniq
      self.availability_mask = indices.reduce(0) { |mask, i| mask | (1 << i) }
    end
  
    def expired?
      created_at.present? && created_at < expires_after_days.days.ago
    end

    # ---- Turbo broadcasts for live dashboard ----
    after_create_commit  -> { broadcast_prepend_to "skill_exchange_requests", target: "ser_list" if status_open? }
    after_update_commit  do 
      if status_open? && !expired?
        broadcast_replace_to "skill_exchange_requests"
      else
        broadcast_remove_to "skill_exchange_requests"
      end
    end
    after_destroy_commit -> { broadcast_remove_to "skill_exchange_requests" }

    # Handy scopes for the dashboard
    scope :recent_first, -> { order(created_at: :desc) }
    scope :status_open_only, -> { where(status: statuses[:open]) } # enum scope helper
  
    private
  
    def availability_days_must_be_selected
      if availability_mask.to_i.zero?
        errors.add(:availability_days, "must include at least one day")
      end
    end
  end
  