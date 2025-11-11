Feature: Dashboard basics
  As a logged-in student
  I can see and filter skill exchange requests

  Background:
    Given I am logged in as "me@columbia.edu"
    And the following skill exchange requests exist:
      | user_email        | teach_skill | learn_skill | modality  | expires_after_days |
      | maya@columbia.edu | Piano       | Python      | remote    | 30                 |
      | alex@columbia.edu | Guitar      | Spanish     | in_person | 14                 |

  Scenario: Dashboard loads and shows cards
    When I visit "/dashboard"
    Then I should see "Explore Skill Exchanges"
    And I should see "Piano"
    And I should see "Spanish"

