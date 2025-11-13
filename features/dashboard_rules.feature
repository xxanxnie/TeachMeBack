Feature: Visibility & live updates
  Background:
    Given I am logged in as "me@columbia.edu"

  Scenario: Closed and expired requests are hidden
    Given a closed skill exchange request exists
    And an expired skill exchange request exists
    When I visit "/dashboard"
    Then I should not see "Closed"
    And I should not see "Expired"

  Scenario: New request appears live
    When I visit "/dashboard"
    And a new open request is created by "new@columbia.edu" with teach "Guitar" and learn "Data Viz"
    Then I should see "Teaching: Guitar"
    And I should see "Learning: Data Viz"
