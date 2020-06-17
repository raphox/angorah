require 'website_scrapper'

# TODO: Implement worker with sidekiq
class WebsiteScrapperWorker
  def perform(user_id, klass = User)
    user = klass.find(user_id)
    attributes = WebsiteScrapper.titles(user.website)

    user.update!(attributes.merge({ skip_load_website_titles: true }))
  end
end
