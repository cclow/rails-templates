require "faker"
require "factory_girl/syntax/sham"

Dir.glob(File.join(File.dirname(__FILE__), "/factories/*.rb")).each { |f| require f }
