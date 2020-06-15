module UserSync
  extend ActiveSupport::Concern

  included do
    after_save :save_neoj4
    before_destroy :destroy_neoj4
  end

  def save_neoj4
    return unless (attributes.keys - ['updated_at']).any?

    params = attributes.slice(
      'first_name',
      'last_name',
      'slug',
      'website',
      'titles',
      'subtitles',
      'introduction'
    ).merge({ 'skip_load_website_titles' => true })

    if neo4j_uuid.present?
      user = UserNeo4j.find(neo4j_uuid)
      user.update(params)
    else
      user = UserNeo4j.create(params)

      # update without callbacks
      set({ neo4j_uuid: user.uuid })
    end
  end

  def destroy_neoj4
    return unless neo4j_uuid.present?

    begin
      UserNeo4j.find(neo4j_uuid).destroy
    rescue StandardError
      nil
    end

    set({ neo4j_uuid: nil })
  end
end
