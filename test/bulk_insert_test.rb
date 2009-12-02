require 'test_helper'
require 'bulk_insert'

class BulkInsertTest < ActiveSupport::TestCase
  
  test "bulk insert" do
    Post.bulk_insert(%w{title body}, [%w{a b}, %w{c d}])
    assert_equal 2, Post.count
    assert_equal "a", Post.first.title
    assert_equal "b", Post.first.body
    assert_equal "c", Post.last.title
    assert_equal "d", Post.last.body
  end
  
  test "bulk update" do
    post_a = Post.create!(:title => "Title A", :body => "Body a.")
    post_b = Post.create!(:title => "Title B", :body => "Body b.")
    Post.bulk_update(%w{id title body}, [[post_a.id, "New Title A", "New body a."], [post_b.id, "New Title B", "New body b."]])
    post_a.reload
    assert_equal "New Title A", post_a.title
    assert_equal "New body a.", post_a.body
    post_b.reload
    assert_equal "New Title B", post_b.title
    assert_equal "New body b.", post_b.body
  end
  
  test "bulk insert with emtpy data" do
    Post.bulk_insert(%w{title body}, [])
    assert_equal 0, Post.count
  end
  
  test "bulk insert with symbols for column names" do
    Post.bulk_insert([:title, :body], [["a", "b"]])
    assert_equal 1, Post.count
    assert_equal "a", Post.first.title
    assert_equal "b", Post.first.body
  end
  
end
