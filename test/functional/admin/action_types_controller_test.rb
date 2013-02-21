require 'test_helper'

class Admin::ActionTypesControllerTest < ActionController::TestCase
  setup do
    @action_type = admin_action_types(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:admin_action_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create admin_action_type" do
    assert_difference('Admin::ActionType.count') do
      post :create, admin_action_type: {  }
    end

    assert_redirected_to admin_action_type_path(assigns(:admin_action_type))
  end

  test "should show admin_action_type" do
    get :show, id: @action_type
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @action_type
    assert_response :success
  end

  test "should update admin_action_type" do
    put :update, id: @action_type, admin_action_type: {  }
    assert_redirected_to admin_action_type_path(assigns(:admin_action_type))
  end

  test "should destroy admin_action_type" do
    assert_difference('Admin::ActionType.count', -1) do
      delete :destroy, id: @action_type
    end

    assert_redirected_to admin_action_types_path
  end
end
