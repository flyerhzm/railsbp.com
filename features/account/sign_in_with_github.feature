Feature: Sign in with github
  In order to sign in with github
  As a github user
  I want to click an icon and be signed in

  Scenario: Successful sign in with github
    Given I am on the homepage
    When I click "Sign in with Github"
    Then I should see "Successfully authorized from Github account."
    And I should see "flyerhzm"
