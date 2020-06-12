require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'load website titles' do
    user = build(:user, { skip_get_website_titles: false })

    stub_request(:get, user.website).
      to_return({
        status: 200,
        body: "<h1>Title h1</h1><h2>Title h2 A</h2><h2>Title h2 B</h2>",
        headers: { "Content-Type" => "text/html" }
      })

    user.save!
    user.reload

    assert_equal user.titles, ['Title h1']
    assert_equal user.subtitles, ['Title h2 A', 'Title h2 B']
  end
end
