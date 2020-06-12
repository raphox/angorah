require 'website_scrapper'

# TODO: implement worker with sidekiq
class WebsiteScrapperWorker
  def perform(user_id, klass = User)
    user = klass.find(user_id)
    titles = WebsiteScrapper.titles(user.website)

    user.update!(titles.merge({ skip_get_website_titles: true }))
  end
end
