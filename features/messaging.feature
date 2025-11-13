Feature: Messaging between users
  As a signed-in user
  I want to send and view messages
  So I can coordinate skill exchanges

  Background:
    Given a user exists named "Kiel" with email "kiel@columbia.edu" and password "secretpass"
    And a user exists named "John Student" with email "john@columbia.edu" and password "secretpass"
    And a skill exchange request exists for "John Student" teaching "Python" and learning "Guitar"
    And I am signed in as "kiel@columbia.edu" with password "secretpass"

  Scenario: Open a thread from the Explore card and send a message
    When I visit the explore page
    And I click "Send message" on the request card for "John Student"
    Then I should be on the message thread with "John Student"
    When I fill in "Message" with "Hey John, I can meet this week."
    And I press "Send"
    Then I should see "Sent."
    And I should see "Hey John, I can meet this week."

  Scenario: Validation error on empty message
    When I visit the explore page
    And I click "Send message" on the request card for "John Student"
    And I press "Send"
    Then I should see "blank"

  Scenario: See previous messages in the thread
    Given a message exists from "John Student" to "Kiel" with body "Yo, are you free Thursday?"
    When I go to the message thread with "John Student"
    Then I should see "Yo, are you free Thursday?"

