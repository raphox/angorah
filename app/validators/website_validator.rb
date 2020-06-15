class WebsiteValidator < ActiveModel::EachValidator
  def validate_each(record, _attribute, value)
    HTTParty.get(value, { timeout: 5 })
  rescue StandardError => e
    record.errors[:attribute] << e.message
  end
end
