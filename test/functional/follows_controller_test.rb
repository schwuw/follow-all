require 'test_helper'

class FollowsControllerTest < ActionController::TestCase
  test 'should follow all users on a list' do
    session[:access_token] = 'abc'
    session[:access_secret] = '123'
    stub_request(:get, 'https://api.twitter.com/1/account/verify_credentials.json').
      to_return(:body => File.read(File.expand_path('../../fixtures/user.json', __FILE__)), :status => 200)
    stub_request(:get, "https://api.twitter.com/1/users/show.json?screen_name=sferik").
      to_return(:body => File.read(File.expand_path('../../fixtures/user.json', __FILE__)), :status => 200)
    stub_request(:get, "https://api.twitter.com/1/lists/members.json?cursor=-1&owner_screen_name=codeforamerica&slug=team").
      to_return(:body => File.read(File.expand_path('../../fixtures/members.json', __FILE__)), :status => 200)
    stub_request(:post, "https://api.twitter.com/1/friendships/create.json").
      to_return(:body => File.read(File.expand_path('../../fixtures/user.json', __FILE__)), :status => 200)
    post :create, :list => "codeforamerica/team"
    assert_not_nil assigns :user
    assert_not_nil assigns :new_friends
    assert_equal 'You are now following 20 new people.', flash[:notice]
    assert_response :success
    assert_select 'title', 'Follow All'
    assert_select 'ul.media-grid li', :count => 20
    assert_select 'form' do
      assert_select '[action=?]', '/follows'
      assert_select '[method=?]', 'post'
    end
    assert_select 'select[name="list"]' do
      assert_select '[value=?]', 'codeforamerica/team'
    end
    assert_select 'button', 'Follow all members of this list!'
  end

  test 'should redirect to failure path when unauthenticated' do
    post :create, :list => "codeforamerica/team"
    assert_redirected_to failure_path
  end
end
