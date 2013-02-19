require 'test_helper'

class Admin::AwardsControllerTest < ActionController::TestCase
  setup do
    @award = admin_awards(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:admin_awards)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create admin_award" do
    assert_difference('Admin::Award.count') do
      post :create, admin_award: {  }
    end

    assert_redirected_to admin_award_path(assigns(:admin_award))
  end

  test "should show admin_award" do
    get :show, id: @award
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @award
    assert_response :success
  end

  test "should update admin_award" do
    put :update, id: @award, admin_award: {  }
    assert_redirected_to admin_award_path(assigns(:admin_award))
  end

  test "should destroy admin_award" do
    assert_difference('Admin::Award.count', -1) do
      delete :destroy, id: @award
    end

    assert_redirected_to admin_awards_path
  end
end
