require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get login page" do
    get login_url
    assert_response :success
  end

  test "should login with valid credentials" do
    manager = customer_success_managers(:one)

    post session_url, params: { email: manager.email, password: "password" }

    assert_redirected_to root_url
  end

  test "should reject invalid credentials" do
    manager = customer_success_managers(:one)

    post session_url, params: { email: manager.email, password: "wrong-password" }

    assert_response :unprocessable_entity
  end

  test "should logout" do
    sign_in_as(customer_success_managers(:one))

    delete logout_url

    assert_redirected_to login_url
  end
end
