Feature: Express interest in a skill exchange request
  As a logged-in user
  I want to express interest in others' requests
  So I can create matches or see validation alerts

  Background:
    Given I am logged in as a user with email "poster@school.edu" and password "secretpass"
    And I have an open skill exchange request teaching "Chemistry" and learning "Design"

  Scenario: Posting interest in another user's request
    Given I am logged in as a user with email "seeker@school.edu" and password "secretpass"
    And I have an open skill exchange request teaching "Physics" and learning "Guitar"
    When I post express interest for the request teaching "Chemistry"
    Then a user skill request should exist with teach skill "Chemistry"

  Scenario: Cannot express interest in own request
    When I post express interest for the request teaching "Chemistry"
    Then I should see "You can't express interest in your own request."
