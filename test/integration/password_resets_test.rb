require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:bond)
  end
  
  test 'password resets' do
    #Invalid email
    get new_password_reset_path
    assert_template 'password_resets/new'
    #Valid email
    post password_resets_path, password_reset: {email: ''}
    assert_not flash.empty?
    assert_template 'password_resets/new'
    post password_resets_path, password_reset: {email: @user.email}
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
    #Password reset form
    user = assigns(:user)
    #Wrong email
    get edit_password_reset_path(user.reset_token, email: '')
    assert_redirected_to root_url
    # Inactive user
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_url
    user.toggle!(:activated)
    #right email and token
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    assert_select 'input[name=email][type=hidden][value=?]', user.email
    #invalid password
    patch password_reset_path(user.reset_token), 
      email: user.email,
      user: { password: 'foobarks',
              password_confirmation: 'fizzytime' }
    assert_select 'div#error_explanation'
    #empty password
    patch password_reset_path(user.reset_token), 
      email: user.email,
      user: { password: '',
              password_confirmation: '' }
    assert_select 'div#error_explanation'
    #valid password and confirmation
    patch password_reset_path(user.reset_token), 
      email: user.email,
      user: { password: 'password',
              password_confirmation: 'password' }
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to user
  end
end







