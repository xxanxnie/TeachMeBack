Feature: Filtering skills on explore
  As a learner and instructor
  I want to use the explore filters
  So I can quickly find matching skill exchange requests

  Background:
    Given the following users exist:
      | full_name     |
      | Casey Creator |
      | Avery Artist  |
      | Taylor Tech   |

  Scenario: Instructor filters by category and availability day
    And the following skill exchange requests exist:
      | user_name     | teach_skill | teach_level | teach_category | learn_skill | learn_level | learn_category | modality | status | availability_days |
      | Casey Creator | Guitar      | advanced    | music_art      | Python      | beginner    | tech_academics | remote   | open   | Tue               |
      | Avery Artist  | Painting    | intermediate | music_art      | Spanish     | beginner    | language       | remote   | open   | Mon               |
    When I visit the explore page as "Casey Creator"
    Then I should see "Guitar"
    And I should see "Painting"
    When I visit "/explore?role[]=instructor&categories[]=tech_academics&days[]=mon"
    Then I should not see "Guitar"
    And I should not see "Painting"
    When I visit "/explore?role[]=instructor&categories[]=tech_academics&days[]=tue"
    Then I should see "Guitar"
    And I should not see "Painting"

  Scenario: Student filters by teach category
    And the following skill exchange requests exist:
      | user_name     | teach_skill | teach_level | teach_category | learn_skill | learn_level | learn_category | modality | status | availability_days |
      | Casey Creator | Guitar      | advanced    | music_art      | Python      | beginner    | tech_academics | remote   | open   | Tue               |
      | Avery Artist  | Painting    | intermediate | music_art      | Spanish     | beginner    | language       | remote   | open   | Mon               |
    When I visit the explore page as "Casey Creator"
    Then I should see "Guitar"
    And I should see "Painting"
    When I visit "/explore?role[]=student&categories[]=tech_academics"
    Then I should not see "Guitar"
    And I should not see "Painting"
    When I visit "/explore?role[]=student&categories[]=music_art"
    Then I should see "Guitar"
    And I should see "Painting"

  Scenario: Instructor filters for language learners
    And the following skill exchange requests exist:
      | user_name     | teach_skill | teach_level | teach_category | learn_skill | learn_level | learn_category | modality | status | availability_days |
      | Casey Creator | Guitar      | advanced    | music_art      | Python      | beginner    | tech_academics | remote   | open   | Tue               |
      | Avery Artist  | Painting    | intermediate | music_art      | Spanish     | beginner    | language       | remote   | open   | Mon               |
    When I visit the explore page as "Avery Artist"
    Then I should see "Guitar"
    And I should see "Painting"
    When I visit "/explore?role[]=instructor&categories[]=language&days[]=mon"
    Then I should see "Painting"
    And I should not see "Guitar"
    When I visit "/explore?role[]=instructor&categories[]=language&days[]=tue"
    Then I should not see "Painting"

  Scenario: Day filters without roles
    And the following skill exchange requests exist:
      | user_name     | teach_skill    | teach_level | teach_category  | learn_skill | learn_level | learn_category | modality | status | availability_days |
      | Casey Creator | Guitar         | advanced    | music_art       | Python      | beginner    | tech_academics | remote   | open   | Tue               |
      | Avery Artist  | Painting       | intermediate | music_art      | Spanish     | beginner    | language       | remote   | open   | Mon               |
      | Taylor Tech   | Data Science   | intermediate | tech_academics | Violin      | beginner    | music_art      | remote   | open   | Thu               |
    When I visit the explore page as "Taylor Tech"
    Then I should see "Guitar"
    And I should see "Painting"
    And I should see "Data Science"
    When I visit "/explore?days[]=thu"
    Then I should see "Data Science"
    And I should not see "Guitar"
    And I should not see "Painting"
    When I visit "/explore?days[]=mon&days[]=tue"
    Then I should see "Guitar"
    And I should see "Painting"
    And I should not see "Data Science"
