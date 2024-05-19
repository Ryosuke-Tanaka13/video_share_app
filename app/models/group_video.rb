class GroupVideo < ApplicationRecord
  belongs_to :group
  belongs_to :video
end
