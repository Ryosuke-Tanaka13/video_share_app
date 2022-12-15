module Viewers::VideoStatusesHelper
  # 視聴率を計算し戻り値を返す
  def culuculate_watched_ratio
    # 下記の数字の例は、左が再生完了地点、右が動画の総時間。(最後まで再生した場合でも、再生完了時点と動画の総時間はぴったりイコールにはならない。)
    # 12.5と12.8などの場合 → 12/12*100 → 視聴率は100.0%
    if params[:video_status][:latest_end_point].to_i == params[:video_status][:total_time].to_i
      ((params[:video_status][:latest_end_point].to_i / params[:video_status][:total_time].to_i).to_f).round(2) * 100
    # 6.5と12.8などの場合 → 6/12*100 → 50.0%
    elsif (params[:video_status][:latest_end_point].to_i < params[:video_status][:total_time].to_i) \
      && ((params[:video_status][:latest_end_point].to_f - params[:video_status][:total_time].to_f) > 1.0)
      ((params[:video_status][:latest_end_point].to_f).floor(0) / (params[:video_status][:total_time].to_f).floor(0).to_f).round(2) * 100
    # 11.9と12.8などの場合(再生完了時点が1秒未満の誤差で動画の総時間に満たない場合) → 12/12*100 → 100.0%
    elsif (params[:video_status][:latest_end_point].to_i < params[:video_status][:total_time].to_i) \
      && ((params[:video_status][:latest_end_point].to_f - params[:video_status][:total_time].to_f) < 1.0)
      ((params[:video_status][:latest_end_point].to_f).ceil(0) / (params[:video_status][:total_time].to_f).floor(0).to_f).round(2) * 100
    end
  end

  # 最後まで視聴が完了していればtrueを返す
  def completely_watched?
    return true if culuculate_watched_ratio == 100

    false
  end
end
