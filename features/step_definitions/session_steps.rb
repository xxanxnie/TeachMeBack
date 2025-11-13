Given("I am not logged in") do
  visit "/logout"
end

When("I visit the dashboard page")     { visit explore_path }
When("I visit the profile page")       { visit profile_path }
When("I visit the new request page")   { visit new_skill_exchange_request_path }
When("I visit the match page")         { visit match_path }
When("I visit the explore page")       { visit explore_path }

Then("I should be on the login page") do
  # Redirects now go to root path, which contains the login form
  assert(page.has_current_path?("/") || page.has_current_path?(login_path))
end
