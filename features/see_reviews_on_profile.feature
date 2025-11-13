Feature: See received reviews on profile

  As a verified user
  I want to view reviews others have written about me
  So that I can reflect on feedback and build trust

  Background:
    Given the following users exist:
      | name  | email           | password |
      | Alice | alice@school.edu | secret   |
      | Bob   | bob@school.edu   | secret   |
    And Bob is logged in
    And Bob has received a review from Alice:
      | rating | content        |
      | 5      | Very helpful!  |

  Scenario: Bob sees his review and average rating
    When Bob visits their profile
    Then they should see "Average Rating: 5.0"
    And they should see "Very helpful!"
