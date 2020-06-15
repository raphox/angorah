FactoryBot.define do
  factory :user do
    first_name { Faker::Name.unique.first_name }
    last_name { Faker::Name.last_name }
    website { Faker::Internet.unique.url }
    titles { Array.new(5) { Faker::University.name } }
    subtitles { Array.new(5) { Faker::University.name } }
    introduction { Faker::Lorem.paragraphs }
    skip_load_website_titles { true }
  end
end
