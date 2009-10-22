generate(:model, "User", "--skip-fixture")
run "ed app/models/user.rb <<-USER
/end/
i
  devise # :confirmable, :recoverable, :rememberable, :validatable
.
w
q
USER"
run "ed db/migrate/*create_users.rb <<-MIGRATE
/create_table/
a
      t.authenticable
      # t.confirmable
      # t.recoverable
      # t.rememberable
      # t.timestamps
.
w
q
MIGRATE"

gem "warden", :source => "http://gemcutter.org/"
gem "devise", :source => "http://gemcutter.org/"

require "warden" rescue rake "gems:install GEM=warden", :sudo => true
require "devise" rescue rake "gems:install GEM=devise", :sudo => true

route "map.devise_for :users"
rake "db:migrate"

run %Q|ed features/support/paths.rb <<-PATHS
/case/
a

      when "the signin page"
        new_user_session_url
.
w
q
PATHS|

run "mkdir -p features/auth"
file "features/auth/signin.feature", <<-SIGNIN
Feature: User can sign in
  In order to identify registered users
  A user
  Can sign in

  Scenario Outline: Sign in
    Given I am registered
    When I go to the signin page
    And I fill in "email" with <email>
    And I fill in "password" with <password>
    And I press "sign in"
    Then I should <result>

    Examples:
      | email      | password      | result                              |
      | my "email" | my "password" | see /Signed in successfully/        |
      | ""         | my "password" | see /Invalid email or password/     |
      | "bademail" | my "password" | see /Invalid email or password/     |
      | my "email" | ""            | see /Invalid email or password/     |
      | my "email" | "badsecret"   | see /Invalid email or password/     |
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
  Then %Q(I should see /Signed in successfully/)
end
AUTH_STEPS

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

git :add => "."
git :commit => "-m 'add devise & warden authentication'"
