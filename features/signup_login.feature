Feature: User signup, login, and .edu verification
  As a student
  I want to create an account with my .edu email and log in
  So I can use TeachMeBack safely

  Background:
    Given I am on the home page

  Scenario: Successful signup with .edu email
    When I follow "Sign up"
    And I fill in "First name" with "Kiel"
    And I fill in "Last name" with "Malate"
    And I fill in "Email" with "km3851@columbia.edu"
    And I fill in "Password" with "secretpass"
    And I press "Create Account"
    Then I should be on the login page
    And I should see "Log in"

  Scenario: Signup fails for non .edu email
    When I follow "Sign up"
    And I fill in "First name" with "Kiel"
    And I fill in "Last name" with "Malate"
    And I fill in "Email" with "kiel@gmail.com"
    And I fill in "Password" with "secretpass"
    And I press "Create Account"
    Then I should see ".edu email required"

  Scenario: Signup fails for blank email
    When I follow "Sign up"
    And I fill in "First name" with "Casey"
    And I fill in "Last name" with "Creator"
    And I fill in "Email" with ""
    And I fill in "Password" with "secretpass"
    And I press "Create Account"
    Then I should see "Email can't be blank"

  Scenario: Login and logout
    Given a user exists with email "km3851@columbia.edu" and password "secretpass"
    When I follow "Log in"
    And I fill in "Email" with "km3851@columbia.edu"
    And I fill in "Password" with "secretpass"
    And I press "Log In"
    Then I should see "Logged in successfully"
    And I should be on the dashboard page
    When I press "Logout"
    Then I should be on the login page
