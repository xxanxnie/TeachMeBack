Feature: User Matching
  As a user
  I want to send requests to other users and get matched when there's mutual interest
  So I can connect with people who want to exchange skills

  Background:
    Given the following users exist:
      | full_name    |
      | Alice Smith  |
      | Bob Johnson  |
      | Charlie Brown|
    And the following skill exchange requests exist:
      | user_email        | teach_skill | learn_skill | modality   | expires_after_days |
      | alice@columbia.edu| Piano       | Python      | remote     | 30                 |
      | bob@columbia.edu  | Guitar      | Spanish     | in_person  | 14                 |
      | charlie@columbia.edu | Python   | Piano       | hybrid     | 30                 |

  Scenario: User can send a TeachMeBack request
    Given I am logged in as "alice@columbia.edu"
    When I visit the explore page
    And I click "TeachMeBack Request" on the skill request card for "Bob Johnson"
    Then I should see "Request sent to Bob Johnson."
    And I should be on the explore page
    And a user skill request should exist from "Alice Smith" to "Bob Johnson" for skill "Guitar"

  Scenario: Button shows "Request Sent" after sending a request
    Given I am logged in as "alice@columbia.edu"
    And a user skill request exists from "Alice Smith" to "Bob Johnson" for skill "Guitar"
    When I visit the explore page
    Then I should see "Request Sent" button on the skill request card for "Bob Johnson"
    And I should not see "TeachMeBack Request" button on the skill request card for "Bob Johnson"

  Scenario: Users get matched when both send requests to each other
    Given I am logged in as "alice@columbia.edu"
    And a user skill request exists from "Bob Johnson" to "Alice Smith" for skill "Piano"
    When I visit the explore page
    And I click "TeachMeBack Request" on the skill request card for "Bob Johnson"
    Then I should see "Congrats, it's a match! You and Bob Johnson expressed interest in each other!"
    And a match should exist between "Alice Smith" and "Bob Johnson"

  Scenario: Matched users see "Matched!" button instead of request button
    Given I am logged in as "alice@columbia.edu"
    And a match exists between "Alice Smith" and "Bob Johnson"
    When I visit the explore page
    Then I should see "✓ Matched!" button on the skill request card for "Bob Johnson"
    And I should not see "TeachMeBack Request" button on the skill request card for "Bob Johnson"
    And I should not see "Request Sent" button on the skill request card for "Bob Johnson"

  Scenario: User cannot send request to themselves
    Given I am logged in as "alice@columbia.edu"
    When I visit the explore page
    Then I should not see "TeachMeBack Request" button on the skill request card for "Alice Smith"

  Scenario: User cannot send duplicate requests
    Given I am logged in as "alice@columbia.edu"
    And a user skill request exists from "Alice Smith" to "Bob Johnson" for skill "Guitar"
    When I visit the explore page
    And I try to send a request to "Bob Johnson"
    Then I should see "You have already sent a request to this user"
    And only one user skill request should exist from "Alice Smith" to "Bob Johnson"

  Scenario: User can view their matches
    Given I am logged in as "alice@columbia.edu"
    And a match exists between "Alice Smith" and "Bob Johnson"
    And a match exists between "Alice Smith" and "Charlie Brown"
    When I visit the match page
    Then I should see "Your Matches"
    And I should see "Bob Johnson"
    And I should see "Charlie Brown"
    And I should see "Mutual Matches"
    And I should see a match count of 2

  Scenario: User sees empty state when they have no matches
    Given I am logged in as "alice@columbia.edu"
    When I visit the match page
    Then I should see "No matches yet"
    And I should see "Start exploring and send requests to find your matches!"
    And I should see a link to "Explore"

  Scenario: Match is created when second user sends request back
    Given I am logged in as "alice@columbia.edu"
    And a user skill request exists from "Alice Smith" to "Bob Johnson" for skill "Guitar"
    When I log out
    And I am logged in as "bob@columbia.edu"
    And I visit the explore page
    And I click "TeachMeBack Request" on the skill request card for "Alice Smith"
    Then I should see "Congrats, it's a match! You and Alice Smith expressed interest in each other!"
    And a match should exist between "Alice Smith" and "Bob Johnson"

  Scenario: Match works regardless of which user sends request first
    Given I am logged in as "bob@columbia.edu"
    And a user skill request exists from "Bob Johnson" to "Alice Smith" for skill "Piano"
    When I log out
    And I am logged in as "alice@columbia.edu"
    And I visit the explore page
    And I click "TeachMeBack Request" on the skill request card for "Bob Johnson"
    Then I should see "Congrats, it's a match! You and Bob Johnson expressed interest in each other!"
    And a match should exist between "Alice Smith" and "Bob Johnson"

  Scenario: Multiple users can match with the same user
    Given I am logged in as "alice@columbia.edu"
    And a user skill request exists from "Bob Johnson" to "Alice Smith" for skill "Piano"
    And a user skill request exists from "Charlie Brown" to "Alice Smith" for skill "Piano"
    When I visit the explore page
    And I click "TeachMeBack Request" on the skill request card for "Bob Johnson"
    Then I should see "Congrats, it's a match! You and Bob Johnson expressed interest in each other!"
    And a match should exist between "Alice Smith" and "Bob Johnson"
    When I click "TeachMeBack Request" on the skill request card for "Charlie Brown"
    Then I should see "Congrats, it's a match! You and Charlie Brown expressed interest in each other!"
    And a match should exist between "Alice Smith" and "Charlie Brown"
    And a match should exist between "Alice Smith" and "Bob Johnson"

  Scenario: Match persists after both users log out and back in
    Given I am logged in as "alice@columbia.edu"
    And a match exists between "Alice Smith" and "Bob Johnson"
    When I log out
    And I am logged in as "alice@columbia.edu"
    And I visit the match page
    Then I should see "Bob Johnson"
    And I should see a match count of 1

  Scenario: User cannot see request button when not logged in
    Given I am not logged in
    When I visit the explore page
    Then I should not see "TeachMeBack Request" button on any skill request card

  Scenario: Match shows correct other user information
    Given I am logged in as "alice@columbia.edu"
    And a match exists between "Alice Smith" and "Bob Johnson"
    When I visit the match page
    Then I should see "Bob Johnson"
    And I should see "bob@columbia.edu"
    And I should not see "Alice Smith" in the match cards

