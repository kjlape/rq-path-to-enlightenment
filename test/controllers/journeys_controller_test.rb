require "test_helper"

class JourneysControllerTest < ActionDispatch::IntegrationTest
  setup do
    @journey = journeys(:one)
    sign_in_as users(:lazaro_nixon)
  end

  test "should get index" do
    get journeys_url
    assert_response :success
  end

  test "should get new" do
    get new_journey_url
    assert_response :success
  end

  test "should create journey" do
    assert_difference("Journey.count") do
      post journeys_url, params: {journey: {description: @journey.description, title: @journey.title}}
    end

    assert_redirected_to journey_url(Journey.last)
  end

  test "should show journey" do
    get journey_url(@journey)
    assert_response :success
  end

  test "should get edit" do
    get edit_journey_url(@journey)
    assert_response :success
  end

  test "should update journey" do
    patch journey_url(@journey), params: {journey: {description: @journey.description, title: @journey.title}}
    assert_redirected_to journey_url(@journey)
  end

  test "should destroy journey" do
    assert_difference("Journey.count", -1) do
      delete journey_url(@journey)
    end

    assert_redirected_to journeys_url
  end
  test "non-admin cannot create journey" do
    sign_in_as users(:one)
    assert_no_difference("Journey.count") do
      post journeys_url, params: { journey: {title: "x", description: "y"}}
    end
    assert_redirected_to root_url
  end

  test "non-admin cannot edit journey" do
    sign_in_as users(:one)
    get edit_journey_url(journeys(:one))
    assert_redirected_to root_url
  end

  test "non-admin cannot destroy journey" do
    sign_in_as users(:one)
    assert_no_difference("Journey.count") do
      delete journey_url(journeys(:one))
    end
    assert_redirected_to root_url
  end
end
