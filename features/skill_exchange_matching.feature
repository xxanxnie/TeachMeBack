Feature: Skill exchange matching, history, and messaging
  As a student
  I want skill exchanges to create clear matches, chat entries, and history
  So I can coordinate and remember my sessions

  Background:
    Given the following users exist:
      | full_name    |
      | Alice Smith  |
      | Bob Johnson  |
    And the following skill exchange requests exist:
      | user_name    | teach_skill | learn_skill | modality   | expires_after_days |
      | Bob Johnson  | Guitar      | Spanish     | remote     | 30                 |

  Scenario: Express interest creates a user skill request but not an immediate match
    Given I am logged in as "alice-smith@columbia.edu"
    When I visit the explore page
    And I click "Express interest" on the skill request card for "Bob Johnson"
    Then I should see "Interest sent to Bob Johnson."
    And a user skill request should exist from "Alice Smith" to "Bob Johnson" for skill "Guitar"
    And a match should not exist between "Alice Smith" and "Bob Johnson"

  Scenario: Mutual interest via Express interest leads directly to chat
    Given I am logged in as "bob-johnson@columbia.edu"
    And a user skill request exists from "Alice Smith" to "Bob Johnson" for skill "Guitar"
    When I log out
    And I am logged in as "alice-smith@columbia.edu"
    And I visit the explore page
    And I click "Express interest" on the skill request card for "Bob Johnson"
    Then a match should exist between "Alice Smith" and "Bob Johnson"
    And I should be on the message thread with "Bob Johnson"
    And I should see "Congrats, it's a match! You and Bob Johnson expressed interest in each other. Start chatting!"

  Scenario: TeachMeBack mutual match flows into chat
    Given I am logged in as "alice-smith@columbia.edu"
    And a user skill request exists from "Bob Johnson" to "Alice Smith" for skill "Guitar"
    When I visit the explore page
    And I click "TeachMeBack Request" on the skill request card for "Bob Johnson"
    Then a match should exist between "Alice Smith" and "Bob Johnson"
    And I should be on the message thread with "Bob Johnson"
    And I should see "Congrats, it's a match! You and Bob Johnson expressed interest in each other. Start chatting!"

  Scenario: Match page links to chat
    Given a match exists between "Alice Smith" and "Bob Johnson"
    And I am logged in as "alice-smith@columbia.edu"
    When I visit the match page
    And I click "💬 Open chat" on the match card for "Bob Johnson"
    Then I should be on the message thread with "Bob Johnson"

  Scenario: Completed exchanges appear in profile history
    Given I am logged in as "bob-johnson@columbia.edu"
    And I have an open skill exchange request teaching "Guitar" and learning "Spanish"
    When I visit my profile page
    Then I should see "Active Skill Exchange Requests"
    And I should see "Guitar" in my active skill exchange list
    When I click "Mark as completed" on my "Guitar" active request
    Then I should see "Skill exchange request updated."
    And I should see "Guitar" in my history skill exchange list


