require File.dirname(__FILE__) + '/../test_helper'

class ScheduledMessagesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:scheduled_messages)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_scheduled_message
    assert_difference('ScheduledMessage.count') do
      post :create, :scheduled_message => { }
    end

    assert_redirected_to scheduled_message_path(assigns(:scheduled_message))
  end

  def test_should_show_scheduled_message
    get :show, :id => scheduled_messages(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => scheduled_messages(:one).id
    assert_response :success
  end

  def test_should_update_scheduled_message
    put :update, :id => scheduled_messages(:one).id, :scheduled_message => { }
    assert_redirected_to scheduled_message_path(assigns(:scheduled_message))
  end

  def test_should_destroy_scheduled_message
    assert_difference('ScheduledMessage.count', -1) do
      delete :destroy, :id => scheduled_messages(:one).id
    end

    assert_redirected_to scheduled_messages_path
  end
end
