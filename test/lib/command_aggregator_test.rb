require "test_helper"

class CommandAggregatorTest < ActiveSupport::TestCase
  test "It should keep track of amount of commands" do
    aggregator = CommandAggregator.new
    aggregator.add("command_1")
    assert_equal 1, aggregator.count

    aggregator.add("command_2")
    assert_equal 2, aggregator.count
  end

  test "#all should return an array with all the commands" do
    aggregator = CommandAggregator.new
    aggregator.add("c1")
    aggregator.add("c2")
    assert_equal ["c1", "c2"], aggregator.commands
  end
end
