Feature: Explore dashboard
  As a signed-in user
  I want to browse open skill exchange requests
  So I can find people to teach or learn with

  Background:
    Given the following users exist:
      | full_name     |
      | John Student  |
      | Mary Mentor   |

  Scenario: Guests do not see Explore in the nav
    When I visit the home page as a guest
    Then I should not see a link to the explore page

  Scenario: Guests are redirected if they visit /explore directly
    When I visit the explore page as a guest
    Then I should be on the home page
    And I should see "Please log in to access explore."

  Scenario: Shows only OPEN and recent requests (<= 180 days) and counts them
    Given the following skill exchange requests exist:
      | teach_skill | learn_skill | modality  | status | created_days_ago | user_name    |
      | Python      | Guitar      | Remote    | open   | 5                | John Student |
      | Swimming    | Piano       | In person | open   | 10               | Mary Mentor  |
      | Rust        | Yoga        | Remote    | open   | 181              | John Student |
      | Cooking     | SQL         | Remote    | closed | 7                | Mary Mentor  |
    When I visit the explore page as "John Student"
    Then I should see "Explore Skill Exchanges"
    And I should see "Open Skill Exchange Requests"
    And I should see a request count of 2
    And I should see "Python"
    And I should see "Swimming"
    And I should not see "Rust"
    And I should not see "Cooking"

  Scenario: Page has a link to create a new request
    Given the following skill exchange requests exist:
      | teach_skill | learn_skill | modality | status | created_days_ago | user_name    |
      | Python      | Guitar      | Remote   | open   | 1                | John Student |
    When I visit the explore page as "John Student"
    Then I should see a "Create New Request" link to the new request page
