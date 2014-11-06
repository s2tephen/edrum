require 'test_helper'

class LearnControllerTest < ActionController::TestCase
  test "should get learn" do
    get :learn
    assert_response :success
  end

end
