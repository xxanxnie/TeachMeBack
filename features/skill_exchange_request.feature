Feature: Skill Exchange Request
  As a logged-in user
  I want to post skill exchange requests
  So I can find learning partners

  Background:
    Given I am logged in as a user with email "testuser@school.edu" and password "password123"

  Scenario: Successfully create a skill exchange request with all required fields
    When I visit the new request page
    And I fill in "Skill you can teach" with "Guitar"
    And I select "Intermediate" from "Your teaching level"
    And I fill in "Skill you want to learn" with "Python"
    And I select "Beginner" from "Your current level for learning"
    And I fill in "Hours you can offer to teach" with "5"
    And I fill in "Auto-expire after how many days?" with "30"
    And I select "In person" from "How do you want to meet?"
    And I check availability day "Mon"
    And I check availability day "Wed"
    And I press "Post Request"
    Then I should see "Your skill exchange request was posted successfully!"
    And I should be on the explore page

  Scenario: Successfully create a skill exchange request with optional fields
    When I visit the new request page
    And I fill in "Skill you can teach" with "Photography"
    And I select "Advanced" from "Your teaching level"
    And I fill in "Skill you want to learn" with "Spanish"
    And I select "Beginner" from "Your current level for learning"
    And I fill in the textarea "What's your learning goal?" with "Learn conversational Spanish for travel"
    And I fill in "Hours you can offer to teach" with "3"
    And I fill in "Auto-expire after how many days?" with "60"
    And I select "Remote" from "How do you want to meet?"
    And I check availability day "Tue"
    And I check availability day "Thu"
    And I check availability day "Sat"
    And I fill in "Notes (optional)" with "Prefer evenings after 6pm"
    And I press "Post Request"
    Then I should see "Your skill exchange request was posted successfully!"
    And I should be on the explore page

  Scenario: Cannot create request without teach skill
    When I visit the new request page
    And I fill in "Skill you want to learn" with "Python"
    And I select "Beginner" from "Your current level for learning"
    And I select "Intermediate" from "Your teaching level"
    And I fill in "Hours you can offer to teach" with "5"
    And I fill in "Auto-expire after how many days?" with "30"
    And I select "In person" from "How do you want to meet?"
    And I check availability day "Mon"
    And I press "Post Request"
    Then I should see "Teach skill can't be blank"

  Scenario: Cannot create request without learn skill
    When I visit the new request page
    And I fill in "Skill you can teach" with "Guitar"
    And I select "Intermediate" from "Your teaching level"
    And I fill in "Hours you can offer to teach" with "5"
    And I fill in "Auto-expire after how many days?" with "30"
    And I select "In person" from "How do you want to meet?"
    And I check availability day "Mon"
    And I press "Post Request"
    Then I should see "Learn skill can't be blank"

  Scenario: Cannot create request without availability days
    When I visit the new request page
    And I fill in "Skill you can teach" with "Guitar"
    And I select "Intermediate" from "Your teaching level"
    And I fill in "Skill you want to learn" with "Python"
    And I select "Beginner" from "Your current level for learning"
    And I fill in "Hours you can offer to teach" with "5"
    And I fill in "Auto-expire after how many days?" with "30"
    And I select "In person" from "How do you want to meet?"
    And I press "Post Request"
    Then I should see "Availability days must include at least one day"

  Scenario: Cannot create request with offer hours greater than 40
    When I visit the new request page
    And I fill in "Skill you can teach" with "Guitar"
    And I select "Intermediate" from "Your teaching level"
    And I fill in "Skill you want to learn" with "Python"
    And I select "Beginner" from "Your current level for learning"
    And I fill in "Hours you can offer to teach" with "50"
    And I fill in "Auto-expire after how many days?" with "30"
    And I select "In person" from "How do you want to meet?"
    And I check availability day "Mon"
    And I press "Post Request"
    Then I should see "Offer hours must be less than or equal to 40"

  Scenario: Cannot create request with offer hours less than 1
    When I visit the new request page
    And I fill in "Skill you can teach" with "Guitar"
    And I select "Intermediate" from "Your teaching level"
    And I fill in "Skill you want to learn" with "Python"
    And I select "Beginner" from "Your current level for learning"
    And I fill in "Hours you can offer to teach" with "0"
    And I fill in "Auto-expire after how many days?" with "30"
    And I select "In person" from "How do you want to meet?"
    And I check availability day "Mon"
    And I press "Post Request"
    Then I should see "Offer hours must be greater than 0"

  Scenario: Cannot create request with expires_after_days less than 7
    When I visit the new request page
    And I fill in "Skill you can teach" with "Guitar"
    And I select "Intermediate" from "Your teaching level"
    And I fill in "Skill you want to learn" with "Python"
    And I select "Beginner" from "Your current level for learning"
    And I fill in "Hours you can offer to teach" with "5"
    And I fill in "Auto-expire after how many days?" with "5"
    And I select "In person" from "How do you want to meet?"
    And I check availability day "Mon"
    And I press "Post Request"
    Then I should see "Expires after days must be greater than or equal to 7"

  Scenario: Cannot create request with expires_after_days greater than 180
    When I visit the new request page
    And I fill in "Skill you can teach" with "Guitar"
    And I select "Intermediate" from "Your teaching level"
    And I fill in "Skill you want to learn" with "Python"
    And I select "Beginner" from "Your current level for learning"
    And I fill in "Hours you can offer to teach" with "5"
    And I fill in "Auto-expire after how many days?" with "200"
    And I select "In person" from "How do you want to meet?"
    And I check availability day "Mon"
    And I press "Post Request"
    Then I should see "Expires after days must be less than or equal to 180"

