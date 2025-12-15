Feature: See received reviews on profile

  As a verified user
  I want to view reviews others have written about me
  So that I can reflect on feedback and build trust

  Background:
    Given the following users exist:
      | full_name | email            |
      | Alice Doe | alice@school.edu |
      | Bob Doe   | bob@school.edu   |
    And I am logged in as "bob@school.edu"
    And Bob Doe has received a review from Alice Doe:
      | rating | content        |
      | 5      | Very helpful!  |

  Scenario: Bob sees his review and average rating
    When Bob Doe visits their profile
    Then they should see "Rating: 5.0"
    And they should see "Very helpful!"
