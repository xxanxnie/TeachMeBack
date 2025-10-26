require "application_system_test_case"

class UserAuthVerificationsTest < ApplicationSystemTestCase
  test "signup succeeds with .edu email" do
    visit root_path
    click_on "Sign up"

    fill_in "Name", with: "Kiel"
    fill_in "Email", with: "km3851@columbia.edu"
    fill_in "Password", with: "secretpass"
    click_on "Create Account"

    assert_text "Welcome, Kiel"
    assert_text "Your email has been verified as .edu"
  end

  test "signup rejects non .edu email" do
    visit root_path
    click_on "Sign up"

    fill_in "Name", with: "Kiel"
    fill_in "Email", with: "kiel@gmail.com"
    fill_in "Password", with: "secretpass"
    click_on "Create Account"

    assert_text ".edu email required"
  end
end

