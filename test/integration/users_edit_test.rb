require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup 
    @user = users(:bond)
    @other_user = users(:archer)
  end
  
  test 'invalid user update' do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), user: { name: 'foobar',
                                    email: 'foo@invalid',
                                    password: 'foo',
                                    password_confirmation: 'bar'}
    assert_template 'users/edit'
  end
  
  test 'successful update with friendly forwarding' do
    get edit_user_path(@user)
    assert_equal session[:forwarding_url], edit_user_url(@user)
    log_in_as(@user)
    assert_redirected_to edit_user_path(@user)
    assert_equal session[:forwarding_url], nil
    name = 'Foobar'
    email = 'foobar@foobar.com'
    patch user_path(@user), user: {
      name: name,
      email: email,
      password: '',
      password_confirmation: ''
    }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name, @user.name
    assert_equal email, @user.email
  end
end
