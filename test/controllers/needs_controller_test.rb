require "test_helper"

class NeedsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get needs_index_url
    assert_response :success
  end

  test "should get new" do
    get needs_new_url
    assert_response :success
  end

  test "should get create" do
    get needs_create_url
    assert_response :success
  end

  test "should get show" do
    get needs_show_url
    assert_response :success
  end
end
