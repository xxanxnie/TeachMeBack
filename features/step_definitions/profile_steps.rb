def profile_form_for(selector)
  el = find(selector, visible: :all)
  @current_profile_form = el.find(:xpath, "./ancestor::form[1]", visible: :all)
  el
end

When("I set my bio to {string}") do |text|
  field = profile_form_for("textarea[name='user[bio]']")
  field.set(text)
end

When("I set my location to {string}") do |text|
  field = profile_form_for("input[name='user[location]']")
  field.set(text)
end

When("I set my university to {string}") do |text|
  field = profile_form_for("input[name='user[university]']")
  field.set(text)
end

When("I save the profile changes") do
  form = @current_profile_form || find("form[action='/profile']", match: :first, visible: :all)
  within(form) do
    click_button "Save", match: :first, visible: :all
  end
end
