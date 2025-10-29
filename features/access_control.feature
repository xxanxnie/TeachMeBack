Feature: Access control for protected pages

  Scenario: Logged-out user is redirected from dashboard
    Given I am not logged in
    When I visit the dashboard page
    Then I should be on the login page
    And I should see "Please log in to access explore."

  Scenario: Logged-out user is redirected from profile
    Given I am not logged in
    When I visit the profile page
    Then I should be on the login page
    And I should see "Please log in to access your profile."

  Scenario: Logged-out user is redirected from new request page
    Given I am not logged in
    When I visit the new request page
    Then I should be on the login page
    And I should see "Please log in to access this page."

  Scenario: Logged-out user is redirected from match page
    Given I am not logged in
    When I visit the match page
    Then I should be on the login page
    And I should see "Please log in to access this page."

  Scenario: Logged-out user is redirected from explore page
    Given I am not logged in
    When I visit the explore page
    Then I should be on the login page
    And I should see "Please log in to access explore."
