# app/models/skill_exchange_request.rb
class SkillExchangeRequest < ApplicationRecord
    belongs_to :user
    has_many :reviews, dependent: :destroy

    DAYS = %w[Mon Tue Wed Thu Fri Sat Sun].freeze

    attr_accessor :availability_days
  
    enum :status,     { open: 0, matched: 1, closed: 2 },        prefix: true
    enum :teach_level, { beginner: 1, intermediate: 2, advanced: 3 }, prefix: true
    enum :learn_level, { beginner: 1, intermediate: 2, advanced: 3 }, prefix: true
  
    # ---------- REQUIREMENTS (everything required except notes & learning_goal) ----------
    validates :teach_skill, :learn_skill,
              :teach_level, :learn_level,
              :offer_hours, :modality,
              :expires_after_days,
              presence: true
  
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
    # after_create_commit  -> { broadcast_prepend_to "skill_exchange_requests", target: "ser_list" if status_open? }
   # after_update_commit  do 
     # if status_open? && !expired?
       # broadcast_replace_to "skill_exchange_requests"
     # else
       # broadcast_remove_to "skill_exchange_requests"
     # end
    # end
   # after_destroy_commit -> { broadcast_remove_to "skill_exchange_requests" }

    # scopes for the dashboard
    scope :recent_first, -> { order(created_at: :desc) }
    scope :status_open_only, -> { where(status: statuses[:open]) } # enum scope helper
  
    private
  
    def availability_days_must_be_selected
      if availability_mask.to_i.zero?
        errors.add(:availability_days, "must include at least one day")
      end
    end

    # categories keys => display label
    CATEGORIES = {
      "music_art"      => "Music/Art",
      "tech_academics" => "Tech/Academics",
      "sports_fitness" => "Sports/Fitness",
      "language"       => "Language",
      "other"          => "Other"
    }.freeze

    validates :teach_category, :learn_category,
              presence: true,
              inclusion: { in: CATEGORIES.keys }

    # normalize strings
    before_validation do
      self.teach_skill     = teach_skill.to_s.strip
      self.learn_skill     = learn_skill.to_s.strip
      self.teach_category  = teach_category.to_s.strip.presence
      self.learn_category  = learn_category.to_s.strip.presence
    end

    def teach_category_label
      CATEGORIES[teach_category] || teach_category&.humanize
    end

    def learn_category_label
      CATEGORIES[learn_category] || learn_category&.humanize
    end

    # normalize availability days to mask
    before_validation :normalize_availability_days_to_mask

    private

    public :teach_category_label, :learn_category_label

    def normalize_availability_days_to_mask
      values = Array(availability_days)
      return if values.blank?

      self.availability_mask = 0

      values.each do |value|
        idx =
          case value
          when Integer
            value
          else
            normalized = value.to_s.strip.downcase
            if normalized =~ /\A\d+\z/
              normalized.to_i
            else
              DAYS.find_index { |day| day.downcase.start_with?(normalized[0, 3]) }
            end
          end

        next unless idx
        self.availability_mask |= (1 << idx)
      end
    end
  end
