class VideoStatus < ApplicationRecord
  belongs_to :video
  belongs_to :viewer

  def not_completely_watched?
    return true if self.watched_ratio != 100

    false
  end

  def completely_watched?
    return true if self.watched_ratio == 100

    false
  end

  def not_watched_at_all?
    return if self.watched_ratio.zero?

    false
  end

  def correct_latest_start_point?(latest_start_point)
    # 新たにとんでくる再生開始地点 ＝ すでに保存されている再生完了地点である必要がある。→最初の飛ばし再生防止。
    # 新たにとんでくる再生開始地点 < すでに保存されている再生完了地点。→同じ部分を繰り返し視聴する場合の対応
    return true if latest_start_point <= self.latest_end_point.to_f

    false
  end

  def correct_latest_end_point?(latest_end_point)
    # すでに保存されている再生完了地点 < 新たに送られてくる再生完了地点の場合にのみ保存を行う。→同じ部分を繰り返し視聴する場合の対応
    return true if self.latest_end_point.to_f < latest_end_point

    false
  end
end
