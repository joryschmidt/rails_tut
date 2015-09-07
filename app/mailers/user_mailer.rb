class UserMailer < ApplicationMailer

  def account_activation(user)
    @user = user
    @greeting = 'Welcome to the Sample App! Click on the link below to activate your account:'
    mail to: user.email, subject: 'Account Activation'
  end

  def password_reset
    @greeting = "Hi"

    mail to: "to@example.org"
  end
end
