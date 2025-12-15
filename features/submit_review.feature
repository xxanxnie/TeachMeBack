Feature: Submit a review after a skill exchange match

  As a verified user
  I want to leave a review for someone I matched with
  So that I can share feedback and help others

  Background:
    Given the following users exist:
      | full_name | email            |
      | Alice Doe | alice@school.edu |
      | Bob Doe   | bob@school.edu   |
    And I am logged in as "alice@school.edu"
    And Bob Doe has a skill exchange request:
      | teach_skill | learn_skill | expires_after_days | availability_days |
      | Ruby        | Python      | 7                  | Monday,Wednesday  |
    And Alice Doe matched with Bob Doe

  Scenario: Alice submits a review for Bob
    When Alice Doe visits the review form for Bob Doe's match
    And she fills in the review with:
      | rating  | content         |
      | 5       | Very helpful!   |
    And she submits the review
    Then she should be redirected to her profile
    And she should see "Review submitted successfully!"

  Scenario: Bob sees his received review on his profile
    Given no reviews exist
    And bob@school.edu has received a review from Alice Doe:
      | rating  | content          |
      | 4       | Super helpful!   |
    And I am logged in as "bob@school.edu"
    When bob@school.edu visits their profile
    Then they should see "4/5 from Alice Doe"
    And they should see "Super helpful!"
    And they should see "Rating: 4.0"

  Scenario: Multiple reviews update average rating
    Given no reviews exist
    And bob@school.edu has received a review from Alice Doe:
      | rating  | content        |
      | 4       | Solid session  |
    And bob@school.edu also has another review from Charlie Helper:
      | rating  | content       |
      | 2       | Needs polish  |
    And I am logged in as "bob@school.edu"
    When bob@school.edu visits their profile
    Then they should see "Solid session"
    And they should see "Needs polish"
    And they should see "Rating: 3.0"
