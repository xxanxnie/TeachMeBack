Feature: Create and validate skill exchange requests
  As a verified user
  I want to post new skill exchange requests
  So I can connect with partners and avoid invalid submissions

  Background:
    Given I am logged in as a user with email "creator@school.edu" and password "secretpass"

  Scenario: Successfully post a new skill exchange request
    When I visit the new request page
    And I select "Music/Art" from "skill_exchange_request_teach_category"
    And I fill in "skill_exchange_request_teach_skill" with "Guitar"
    And I select "Intermediate" from "skill_exchange_request_teach_level"
    And I select "Tech/Academics" from "skill_exchange_request_learn_category"
    And I fill in "skill_exchange_request_learn_skill" with "Python"
    And I select "Beginner" from "skill_exchange_request_learn_level"
    And I fill in "skill_exchange_request_learning_goal" with "Build a project"
    And I fill in "skill_exchange_request_offer_hours" with "3"
    And I fill in "skill_exchange_request_expires_after_days" with "20"
    And I select "Remote" from "skill_exchange_request_modality"
    And I check availability day "Tue"
    And I press "Post Request"
    Then I should be on the explore page
    And a skill exchange request should exist with teach skill "Guitar"

  Scenario: Validation error when no availability days are chosen
    When I visit the new request page
    And I select "Other" from "skill_exchange_request_teach_category"
    And I fill in "skill_exchange_request_teach_skill" with "Cooking"
    And I select "Beginner" from "skill_exchange_request_teach_level"
    And I select "Language" from "skill_exchange_request_learn_category"
    And I fill in "skill_exchange_request_learn_skill" with "Spanish"
    And I select "Beginner" from "skill_exchange_request_learn_level"
    And I fill in "skill_exchange_request_offer_hours" with "2"
    And I fill in "skill_exchange_request_expires_after_days" with "10"
    And I select "In person" from "skill_exchange_request_modality"
    And I press "Post Request"
    Then I should see "Availability days must include at least one day"
