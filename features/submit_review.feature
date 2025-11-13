Feature: Submit a review after a skill exchange match

  As a verified user
  I want to leave a review for someone I matched with
  So that I can share feedback and help others

  Background:
    Given the following users exist:
      | name  | email           | password |
      | Alice | alice@school.edu | secret   |
      | Bob   | bob@school.edu   | secret   |
    And Alice is logged in
    And Bob has a skill exchange request:
      | teach_skill | learn_skill | expires_after_days | availability_days |
      | Ruby        | Python      | 7                  | Monday,Wednesday  |
    And Alice matched with Bob

  Scenario: Alice submits a review for Bob
    When Alice visits the review form for Bob's match
    And she fills in the review with:
      | rating  | content         |
      | 5       | Very helpful!   |
    And she submits the review
    Then she should be redirected to her profile
    And she should see "Review submitted successfully!"
