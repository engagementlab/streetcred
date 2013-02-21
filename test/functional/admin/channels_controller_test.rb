require 'test_helper'

class Admin::ChannelsControllerTest < ActionController::TestCase
  setup do
    @admin_channel = admin_channels(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:admin_channels)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create admin_channel" do
    assert_difference('Admin::Channel.count') do
      post :create, admin_channel: {  }
    end

    assert_redirected_to admin_channel_path(assigns(:admin_channel))
  end

  test "should show admin_channel" do
    get :show, id: @admin_channel
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @admin_channel
    assert_response :success
  end

  test "should update admin_channel" do
    put :update, id: @admin_channel, admin_channel: {  }
    assert_redirected_to admin_channel_path(assigns(:admin_channel))
  end

  test "should destroy admin_channel" do
    assert_difference('Admin::Channel.count', -1) do
      delete :destroy, id: @admin_channel
    end

    assert_redirected_to admin_channels_path
  end
end
