module ReviewsHelper
  # Returns a simple star representation like "★★★☆☆" for a numeric rating (1-5).
  def star_string(rating)
    filled = rating.to_i.clamp(0, 5)
    empty  = 5 - filled
    "★" * filled + "☆" * empty
  end
end
