require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    stub_request(:get, /.*/).
      to_return({
        status: 200,
        body: '<h1>Title h1</h1><h2>Title h2 A</h2><h2>Title h2 B</h2>',
        headers: { 'Content-Type' => 'text/html' },
      })

    UserNeo4j.stub(:create, UserNeo4jStub.new({ uuid: Faker::Internet.uuid })) do
      @user = create(:user)
    end
  end

  test 'should get index' do
    get users_url
    assert_response :success
  end

  test 'should get new' do
    get new_user_url
    assert_response :success
  end

  test 'should create user' do
    uuid = Faker::Internet.uuid

    UserNeo4j.stub(:create, UserNeo4jStub.new({ uuid: uuid })) do
      UserNeo4j.stub(:find, UserNeo4jStub.new({ uuid: uuid })) do
        assert_difference('User.count') do
          post users_url, params: { user: build(:user).attributes }
        end

        assert_redirected_to user_url(User.last)
      end
    end
  end

  test 'should show user' do
    UserNeo4j.stub(:find, UserNeo4jStub.new({ uuid: Faker::Internet.uuid })) do
      get user_url(@user)
      assert_response :success
    end
  end

  test 'should get edit' do
    get edit_user_url(@user)
    assert_response :success
  end

  test 'should update user' do
    UserNeo4j.stub(:find, UserNeo4jStub.new({ uuid: Faker::Internet.uuid })) do
      patch user_url(@user), params: { user: build(:user).attributes }
      @user.reload
      assert_redirected_to user_url(@user)
    end
  end

  test 'should destroy user' do
    assert_difference('User.count', -1) do
      delete user_url(@user)
    end

    assert_redirected_to users_url
  end
end
