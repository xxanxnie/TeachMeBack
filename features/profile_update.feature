Feature: Update profile information
  As a logged-in user
  I want to edit my profile details
  So others see accurate info about me

  Background:
    Given I am logged in as a user with email "profile@school.edu" and password "secretpass"

  Scenario: Update bio and location/university
    When I visit my profile page
    And I set my bio to "I love teaching music and learning code."
    And I save the profile changes
    And I set my location to "New York, NY"
    And I set my university to "Columbia University"
    And I save the profile changes
    Then I should see "I love teaching music and learning code."
    And I should see "New York, NY"
    And I should see "Columbia University"
