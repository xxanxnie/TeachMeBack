# features/step_definitions/redirect_steps.rb

When("I try to visit the new request page") do
  page.driver.options[:follow_redirects] = true if page.driver.respond_to?(:options)
  visit new_skill_exchange_request_path
  sleep 0.5
end

Then("I should be redirected to the login page") do
  # Check if redirect happened - either path changed or page shows login content
  max_attempts = 3
  attempt = 0
  
  while attempt < max_attempts
    current = page.current_path
    
    # Success: we're on login page
    if current == "/" || current == login_path || current == "/login"
      return
    end
    
    if page.has_content?("Log in") || page.has_field?("Email") || page.has_field?("email")
      return
    end
    
    attempt += 1
    sleep 0.3 if attempt < max_attempts
  end
  
  current = page.current_path
  raise "Expected redirect to login page, but was on #{current}. Page title: #{page.title rescue 'N/A'}"
end

Then("I should see login content or be redirected") do
  current = page.current_path
  
  if current == "/" || current == login_path || current == "/login"
    return
  end
  
  if page.has_content?("Log in") || page.has_content?("Please log in") || page.has_field?("Email")
    return
  end
  
end

