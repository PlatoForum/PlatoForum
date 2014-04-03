require 'test_helper'

class StaticControllerTest < ActionController::TestCase
  test "should get about" do
    get :about
    assert_response :success
  end

  test "should get PrivacyPolicy" do
    get :PrivacyPolicy
    assert_response :success
  end

  test "should get contact" do
    get :contact
    assert_response :success
  end

end
