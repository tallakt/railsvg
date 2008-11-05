require 'test_helper'

class IntTagsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:int_tags)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_int_tag
    assert_difference('IntTag.count') do
      post :create, :int_tag => { }
    end

    assert_redirected_to int_tag_path(assigns(:int_tag))
  end

  def test_should_show_int_tag
    get :show, :id => int_tags(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => int_tags(:one).id
    assert_response :success
  end

  def test_should_update_int_tag
    put :update, :id => int_tags(:one).id, :int_tag => { }
    assert_redirected_to int_tag_path(assigns(:int_tag))
  end

  def test_should_destroy_int_tag
    assert_difference('IntTag.count', -1) do
      delete :destroy, :id => int_tags(:one).id
    end

    assert_redirected_to int_tags_path
  end
end
