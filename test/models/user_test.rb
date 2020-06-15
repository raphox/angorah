require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'load website titles' do
    uuid = Faker::Internet.uuid

    UserNeo4j.stub(:create, UserNeo4jStub.new({ uuid: uuid })) do
      UserNeo4j.stub(:find, UserNeo4jStub.new({ uuid: uuid })) do
        user = build(:user, { skip_load_website_titles: false, neo4j_uuid: uuid })

        stub_request(:get, user.website).
          to_return({
            status: 200,
            body: '<h1>Title h1</h1><h2>Title h2 A</h2><h2>Title h2 B</h2>',
            headers: { 'Content-Type' => 'text/html' },
          })

        user.save!
        user.reload

        assert_equal user.titles, ['Title h1']
        assert_equal user.subtitles, ['Title h2 A', 'Title h2 B']
      end
    end
  end
end
