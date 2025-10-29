Given("I am not logged in") do
  visit logout_path if page.has_link?("Logout")
end

When("I visit the dashboard page")     { visit dashboard_path }
When("I visit the profile page")       { visit profile_path }
When("I visit the new request page")   { visit new_skill_exchange_request_path }
When("I visit the match page")         { visit match_path }
When("I visit the explore page")       { visit explore_path }

Then("I should be on the login page") do
  assert(page.has_current_path?(login_path))
end

Then("I should see {string}") do |text|
  assert(page.has_content?(text))
end
