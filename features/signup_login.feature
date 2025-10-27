Feature: User signup, login, and .edu verification
  As a student
  I want to create an account with my .edu email and log in
  So I can use TeachMeBack safely

  Background:
    Given I am on the home page

  Scenario: Successful signup with .edu email
    When I follow "Sign up"
    And I fill in "Name" with "Kiel"
    And I fill in "Email" with "km3851@columbia.edu"
    And I fill in "Password" with "secretpass"
    And I press "Create Account"
    Then I should see "Welcome, Kiel"
    And I should see "Your email has been verified as .edu"

  Scenario: Signup fails for non .edu email
    When I follow "Sign up"
    And I fill in "Name" with "Kiel"
    And I fill in "Email" with "kiel@gmail.com"
    And I fill in "Password" with "secretpass"
    And I press "Create Account"
    Then I should see ".edu email required"

  Scenario: Login and logout
    Given a user exists with email "km3851@columbia.edu" and password "secretpass"
    When I follow "Log in"
    And I fill in "Email" with "km3851@columbia.edu"
    And I fill in "Password" with "secretpass"
    And I press "Log in"
    Then I should see "Welcome back"
    And I should be on the dashboard page
    When I follow "Log out"
    Then I should see "Signed out"

