Feature: View skill exchange requests
  As a logged-in user
  I want to browse request pages
  So I can review details and lists

  Background:
    Given I am logged in as a user with email "viewer@school.edu" and password "secretpass"
    And I have an open skill exchange request teaching "Painting" and learning "French"

  Scenario: Visit the requests index and show page
    When I visit "/skill_exchange_requests"
    Then I should see "Recent Skill Exchange Requests"
    And I should see "Painting"
    When I view the skill exchange request with teach skill "Painting"
    Then I should see "Painting" in the page
    And I should see "French" in the page
