class WebsiteValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    HTTParty.get(value, { timeout: 10 })
  rescue => e
    record.errors[:attribute] << e.message
  end
end
