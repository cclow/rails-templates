gem "authlogic"

run <<-TEST_HELPER_RUN
cat >> test/test_helper.rb <<-TEST_HELPER
require "authlogic/test_case"

class ActionController::TestCase
  setup :activate_authlogic
end
TEST_HELPER
TEST_HELPER_RUN


generate(:session, "UserSession")
run "mkdir -p features/auth"
file "features/auth/signin.feature", <<-SIGNIN
Feature: User can sign in
  In order to identify registered users
  A user
  Can sign in

@wip
  Scenario Outline: Sign in
    Given I am registered
    When I go to the signin page
    And I fill in "email" with <email>
    And I fill in "password" with <password>
    And I press "sign in"
    Then I should <result>

    Examples:
      | email      | password      | result                   |
      | my "email" | my "password" | see /sign in successful/ |
      | ""         | my "password" | see /sign in failed/     |
      | "bademail" | my "password" | see /sign in failed/     |
      | my "email" | ""            | see /sign in failed/     |
      | my "email" | "badsecret"   | see /sign in failed/     |
SIGNIN

file "features/step_definitions/auth_steps.rb", <<-AUTH_STEPS
Given /^I am registered$/ do
  @user_hash = User.plan
  User.create!(@user_hash)
end

When /^I fill in "([^\\"]*)" with my "([^\\"]*)"$/ do |field, attr|
  When %Q(I fill in "\#{field}" with "\#{@user_hash[attr.to_sym]}")
end

Given /^I am signed in$/ do
  Given %Q(I am registered)
  When %Q(I go to the signin page)
  And %Q(I fill in "email" with my "email")
  And %Q(I fill in "password" with my "password")
  And %Q(I press "sign in")
  Then %Q(I should see /sign in successful/)
end
AUTH_STEPS

file "app/controllers/application_controller.rb", <<-APPLICATION_CONTROLLER
class ApplicationController < ActionController::Base
  helper :all
  helper_method :current_user_session, :current_user
  filter_parameter_logging :password

  private
    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end

    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.record
    end

    def require_user
      unless current_user
        store_location
        flash[:notice] = "You must be logged in to access this page"
        redirect_to signin_url
        return false
      end
    end

    def require_no_user
      if current_user
        store_location
        flash[:notice] = "You must be logged out to access this page"
        redirect_to root_url
        return false
      end
    end

    def store_location
      session[:return_to] = request.request_uri
    end

    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end
end
APPLICATION_CONTROLLER

file "app/controllers/user_sessions_controller.rb", <<-USER_SESSION
class UserSessionsController < ApplicationController
  before_filter :require_user, :only => :destroy

  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:success] = "Sign in successful"
      redirect_back_or_default root_url
    else
      flash[:error] = "Sign in failed"
      redirect_to signin_url
    end
  end

  def destroy
    current_user_session.destroy
    redirect_back_or_default signin_url
  end
end
USER_SESSION

file "app/views/user_sessions/new.html.haml", <<-NEW
- title "Sign in"
- semantic_form_for @user_session do |f|
  -f.inputs do
    =f.input :email
    =f.input :password
    =f.commit_button "Sign in"
NEW

route %Q|map.signin "/signin", :controller => "user_sessions", :action => "new"|
route %Q|map.signout "/signout", :controller => "user_sessions", :action => "destroy"|
route %Q|map.resources :user_sessions, :only => [:create]|

generate(:model, "user", "email:string crypted_password:string password_salt:string persistence_token:string")
rake "db:migrate"

file "app/models/user.rb", <<-USER
class User < ActiveRecord::Base
  acts_as_authentic
end
USER

file "test/machinist/user_bp.rb", <<-USER_BP
Sham.define do
  email                         { Faker::Internet.email }
  password                      { Faker::Lorem.sentence }
end

User.blueprint do
  email                         { Sham.email }
  password                      { Sham.password }
  password_confirmation         { password }
end
USER_BP
