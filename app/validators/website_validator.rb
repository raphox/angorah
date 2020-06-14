class WebsiteValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    HTTParty.get(value, { timeout: 5 })
  rescue => e
    record.errors[:attribute] << e.message
  end
end
