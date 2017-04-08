require 'test_helper'

class Api::V1::ReportsControllerControllerTest < ActionController::TestCase
  test "should get user" do
    get :user
    assert_response :success
  end

  test "should get post" do
    get :post
    assert_response :success
  end

  test "should get archive" do
    get :archive
    assert_response :success
  end

end
