require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get sessions_new_url
    assert_response :success
  end

  test "should post create" do
    post sessions_create_url, params: { email: "test@example.com", password: "password" }
    assert_response :redirect
  end

  test "should get destroy" do
    delete sessions_destroy_url
    assert_response :redirect
  end
end
