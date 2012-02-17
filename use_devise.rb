gem "bcrypt-ruby"
gem "devise"

run "bundle install"

generate "devise:install"

create_file "spec/support/devise.rb" do
%q<
RSpec.configure do |config|
  config.include Devise::TestHelpers, :type => :controller
end
>
end
