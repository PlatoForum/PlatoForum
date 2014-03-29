require 'test_helper'

class StancesControllerTest < ActionController::TestCase
  setup do
    @stance = stances(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:stances)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create stance" do
    assert_difference('Stance.count') do
      post :create, stance: {  }
    end

    assert_redirected_to stance_path(assigns(:stance))
  end

  test "should show stance" do
    get :show, id: @stance
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @stance
    assert_response :success
  end

  test "should update stance" do
    patch :update, id: @stance, stance: {  }
    assert_redirected_to stance_path(assigns(:stance))
  end

  test "should destroy stance" do
    assert_difference('Stance.count', -1) do
      delete :destroy, id: @stance
    end

    assert_redirected_to stances_path
  end
end
