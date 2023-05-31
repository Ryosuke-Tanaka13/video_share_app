class VideoFolder < ApplicationRecord
  belongs_to :video
  belongs_to :folder
end
