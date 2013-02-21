require 'test_helper'

class Admin::CampaignsControllerTest < ActionController::TestCase
  setup do
    @campaign = admin_campaigns(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:admin_campaigns)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create admin_campaign" do
    assert_difference('Admin::Campaign.count') do
      post :create, admin_campaign: {  }
    end

    assert_redirected_to admin_campaign_path(assigns(:admin_campaign))
  end

  test "should show admin_campaign" do
    get :show, id: @campaign
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @campaign
    assert_response :success
  end

  test "should update admin_campaign" do
    put :update, id: @campaign, admin_campaign: {  }
    assert_redirected_to admin_campaign_path(assigns(:admin_campaign))
  end

  test "should destroy admin_campaign" do
    assert_difference('Admin::Campaign.count', -1) do
      delete :destroy, id: @campaign
    end

    assert_redirected_to admin_campaigns_path
  end
end
