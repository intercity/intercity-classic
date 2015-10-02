require "test_helper"

class Intercity::PopenTest < ActiveSupport::TestCase
  setup do
    @klass = Class.new(Object)
    @klass.send(:include, Intercity::Popen)
    @path = Rails.root.join("tmp").to_s
  end

  test "zero status" do
    @output, @status = @klass.new.popen(%W(ls), @path)
    assert_equal 0, @status
    assert_includes @output, 'cache'
  end

  test "non-zero status" do
    @output, @status = @klass.new.popen(%W(cat NOTHING), @path)
    assert_equal 1, @status
    assert_includes @output, "No such file or directory"
  end

  test "unsafe string command" do
    assert_raises RuntimeError do
      @klass.new.popen("ls", @path)
    end
  end

  test "without a dirtory argument" do
    @output, @status = @klass.new.popen(%W(ls))
    assert_equal 0, @status
    assert_includes @output, "test"
  end
end
