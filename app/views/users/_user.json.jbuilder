json.extract! user, :id, :name, :website, :website_data_collection, :created_at, :updated_at
json.url user_url(user, format: :json)
