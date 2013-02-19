require 'test_helper'

class Admin::ActionsControllerTest < ActionController::TestCase
  setup do
    @action = admin_actions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:admin_actions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create admin_action" do
    assert_difference('Admin::Action.count') do
      post :create, admin_action: {  }
    end

    assert_redirected_to admin_action_path(assigns(:admin_action))
  end

  test "should show admin_action" do
    get :show, id: @action
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @action
    assert_response :success
  end

  test "should update admin_action" do
    put :update, id: @action, admin_action: {  }
    assert_redirected_to admin_action_path(assigns(:admin_action))
  end

  test "should destroy admin_action" do
    assert_difference('Admin::Action.count', -1) do
      delete :destroy, id: @action
    end

    assert_redirected_to admin_actions_path
  end
end
