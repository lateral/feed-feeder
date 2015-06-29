require 'awesome_print'

include ApplicationHelper

# def login(user)
#   visit root_path
#   click_link "Login"
#   fill_in 'user_email', with: user.email
#   fill_in 'user_password', with: user.password
#   click_on 'Sign in'
# end
module ValidUserRequestHelper
  # Define a method which signs in as a valid user.
  def sign_in_as(user)
    # ASk factory girl to generate a valid user for us.
    # @user ||= FactoryGirl.create :user

    # We action the login request using the parameters before we begin. The login requests
    # will match these to the user we just created in the factory, and authenticate us.
    post_via_redirect user_session_path,
                      'user[email]' => user.email,
                      'user[password]' => user.password
  end
end

# RSpec::Matchers.define :have_error_message do |message|
#   match do |page|
#     expect(page).to have_selector('div.alert.alert-error', text: message)
#   end
# end

RSpec.configure do |config|
  config.include ValidUserRequestHelper, type: :request
end
