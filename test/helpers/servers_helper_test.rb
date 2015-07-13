require "test_helper"

class ServersHelperTest < ActionView::TestCase
  test "should create database options" do
    assert_equal [["MySQL", :mysql]], db_type_options([:mysql]),
                 "Wrong database options"

    assert_equal [["MySQL", :mysql], ["PostgreSQL", :postgres]],
                 db_type_options([:mysql, :postgres]), "Wrong database options"
  end

  test "chef-repo path should not be null" do
    assert_not_nil chef_repo_path
  end
end
