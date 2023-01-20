class Organizations::Form
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :name, :string
  attribute :email, :string
  attribute :users

  def params
    attributes.deep_symbolize_keys
  end
end
