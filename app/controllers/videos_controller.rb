class VideosController < ApplicationController
  require 'open3'
  require "google/cloud/speech"
  require "google/cloud/storage"
  include CommentReply
  helper_method :account_logged_in?
  before_action :ensure_logged_in, except: :show
  before_action :set_organization, only: %i[index]
  before_action :set_video, only: %i[show edit update destroy video_edit]
  before_action :ensure_admin_or_user, only: %i[new create edit update destroy video_edit]
  before_action :ensure_user, only: %i[new create]
  before_action :ensure_admin_or_owner_or_correct_user, only: %i[update]
  before_action :ensure_admin, only: %i[destroy]
  before_action :ensure_my_organization, exept: %i[new create]
  # 視聴者がログインしている場合、表示されているビデオの視聴グループ＝現在の視聴者の視聴グループでなければ、締め出す下記のメソッド追加予定
  # before_action :limited_viewer, only: %i[show]
  before_action :ensure_logged_in_viewer, only: %i[show]
  before_action :ensure_admin_for_access_hidden, only: %i[show edit update]
  before_action :set_vimeo_api_token, only: [:download_vimeo_video]
  

  def index
    # 動画検索機能用に記載
    @search_params = video_search_params
    if current_system_admin.present?
      # 動画検索機能用に記載 リセットボタン、検索ボタン押下後paramsにorganization_idが含まれないためsessionに保存
      session[:organization_id] = params[:organization_id]
      @organization_videos = Video.includes([:video_blob]).user_has(params[:organization_id])
    elsif current_user.present?
      @organization_videos = Video.includes([:video_blob]).current_user_has(current_user).available
    elsif current_viewer.present?
      # 動画検索機能用に記載 リセットボタン、検索ボタン押下後paramsにorganization_idが含まれないためsessionに保存
      session[:organization_id] = params[:organization_id]
      @organization_videos = Video.includes([:video_blob]).current_viewer_has(params[:organization_id]).available
      # 現在の視聴者の視聴グループに紐づくビデオのみを表示するよう修正が必要(第２フェーズ)
    end
  end

  def new
    @video = Video.new
    @video.video_folders.build
  end

  def create
    @video = Video.new(video_params)
    @video.identify_organization_and_user(current_user)
    if @video.save
      flash[:success] = '動画を投稿しました。'
      redirect_to @video
    else
      render :new
    end
  # アプリ側ではなく、vimeo側に原因があるエラーのとき(容量不足)
  rescue StandardError
    render :new
  end

  def show
    set_account
    @comment = Comment.new
    @reply = Reply.new
    # 新着順で表示
    @comments = @video.comments.includes(:system_admin, :user, :viewer, :replies).order(created_at: :desc)
  end

  #動画編集ページ#
  def video_edit
    respond_to do |format|
      format.html
      format.js
    end
  end

  def edit; end

  def update
    if @video.update(video_params)
      flash[:success] = '動画情報を更新しました'
      redirect_to video_url
    else
      render 'edit'
    end
  end

  def destroy
    vimeo_video = VimeoMe2::Video.new(ENV['VIMEO_API_TOKEN'], @video.data_url)
    vimeo_video.destroy
    @video.destroy
    flash[:success] = '削除しました'
    redirect_to videos_url(organization_id: @video.organization.id)
  rescue VimeoMe2::RequestFailed
    @video.destroy
    flash[:success] = '削除しました'
    redirect_to videos_url(organization_id: @video.organization.id)
  end

  # --------Vimeoの動画を一時ダウンロードする場所ーーーーーーーーー
  desktop_path = Rails.root.join('public', 'videos')
  # FileUtils.mkdir_p(tmp_dir) unless File.directory?(tmp_dir)
  

  def download_vimeo_video
    user_home_directory = Dir.home
    desktop_path = File.join(user_home_directory, 'Desktop')
    output_path = File.join(desktop_path, 'output_video.mp4')

    video_url =  video_url = 'https://vimeo.com/manage/videos/896179079/download'
    access_token = @vimeo_api_token

    download_command = "curl '#{video_url}' -H 'Authorization: Bearer #{access_token}' -L -o '/Users/'shimatanitakahiro@MacBook-Pro/Desktop/output_video.mp4"
    Open3.popen3(download_command) do |stdin, stdout, stderr, wait_thr|
      exit_status = wait_thr.value
      unless exit_status.success?
        # エラーが発生した場合の処理
        puts "エラーが発生しました: #{stderr.read}"
      end
    end
  end
 # -----------------------------------------------------------
 # --------動画編集ーーーーーーーーー
  def cut_video
  end

  def cut_video_edit
    # フォームから送信されたデータを取得
    start_time = params[:start_time]
    duration = params[:duration]
    new_title = params[:new_title]
    video_file = params[:video_file]
    desktop_path = '/app/output'
    puts "desktop_path"
    if File.writable?(desktop_path)
      puts "書き込み権限があります"
    else
      puts "書き込み権限がありません"
    end
    output_filename = "#{new_title}_#{Time.now.to_i}.mp4"
    # ファイルが選択されているか確認
    if video_file.present? && video_file.respond_to?(:tempfile)
      ffmpeg_path = '/usr/bin/ffmpeg'
    
      # ファイルの一時保存先を取得
      input_path = video_file.tempfile.path
      puts "Input Path: #{input_path}"
      
      output_path = File.join(desktop_path, output_filename)
      puts "Output Path: #{output_path}"
      ffmpeg_command = "#{ffmpeg_path} -i '#{input_path}' -ss #{start_time} -t #{duration} -c copy -movflags faststart '#{output_path}'"

      puts "Executing command: #{ffmpeg_command}"
      success = system(ffmpeg_command)
      # コマンドの実行結果を確認
      unless success
        puts "Error executing command: #{ffmpeg_command}"
        flash[:error] = "動画の切り抜きに失敗しました。"
        head :internal_server_error and return
      end
      # 切り抜かれた動画の保存先などをビューに渡す
      flash[:success] = "動画を切り抜きました。作成動画：#{output_filename}"
      redirect_to cut_video_path
    else
      # ファイルが選択されていない場合の処理
      render plain: '動画ファイルを選択してください。'
    end
  end

# ------------------音声出力と音声データ文字起こし、データ統合-----------------------------------------
def create_bucket
  @storage = Google::Cloud::Storage.new(
    project_id: 'learned-fusion-389707',
    credentials: Rails.root.join('gcstoragelearned-fusion-389707-d403d797d105.json'),
    timeout: 1800
  )

  @bucket_name = 'movie_app_bucket'
  @bucket = @storage.bucket(@bucket_name)
  if @bucket.nil?
    @bucket = @storage.create_bucket(@bucket_name)
    puts "Bucket '#{@bucket.name}' created."
  else
    puts "Bucket '#{@bucket.name}' already exists."
  end
  @bucket
rescue StandardError => e
  puts "Error creating bucket: #{e.message}"
end

def audio_output
  require 'shellwords'
  # 動画ファイルのパスをparamsから取得
  video_path = Shellwords.escape(params[:subtitle].tempfile.path)
  # 出力する音声ファイルのパス
  audio_output_path = Rails.root.join('public', 'voice', "extraction#{Time.now.to_i}.wav")
  # ffmpegを使用して動画から音声を抽出し、WAV形式で保存
  # command = "ffmpeg -i #{video_path} -vn -acodec pcm_s16le -ar 44100 -ac 2 #{audio_output_path}"

  command = "ffmpeg -i #{video_path} -vn -acodec pcm_s16le -ar 44100 -ac 1 #{audio_output_path}"
  stdout, stderr, status = Open3.capture3(command)
  if status.success?
    puts "Audio extracted successfully to #{audio_output_path}"
  else
    puts "Failed to extract audio: #{stderr}"
  end
  # Google Cloud Storageの設定
  storage = Google::Cloud::Storage.new
  bucket = storage.bucket 'movie_app_bucket'
  # 音声ファイル名の取得
  audio_file_name = audio_output_path.basename.to_s
  chunk_size = 5 * 1024 * 1024  # 5MB のチャンクサイズ
  # 音声データをアップロードする際のタイムアウトまでの時間を５分に延長する
  options = { timeout: 1800}
  # 音声ファイルをアップロード
  file = bucket.create_file audio_output_path.to_s, "audio_files/#{audio_file_name}"
  # 音声ファイルのGCSパス
  audio = { uri: "gs://movie_app_bucket/audio_files/#{audio_file_name}" }
  # Speech-to-Text API の設定と実行
  speech = Google::Cloud::Speech.speech
  config = { encoding: :LINEAR16, sample_rate_hertz: 44100, language_code: "ja-JP" }
  operation = speech.long_running_recognize config: config, audio: audio
  puts "Transcription operation started, waiting for completion..."
  operation.wait_until_done!
  if operation.error
    puts "Error: #{operation.error.message}"
    render json: { error: operation.error.message }, status: :unprocessable_entity
  else
    response = operation.response
    if response.nil?
      puts "No response received."
      render json: { error: "No response received" }, status: :unprocessable_entity
      return
    else
        # puts "Response: #{response.inspect}"
        # transcripts = response.results.each_with_index do |result, i|
        # puts "Result #{i + 1}:"
        # result.alternatives.each do |alternative|
        # puts "Transcript: #{alternative.transcript}"
        # end
        puts "Response:#{response.inspect}"
        # google-cloud-speech Text-APIの文字起こし出力結果を呼び出している
        transcripts=response.results.flat_map do |result|
        # resultsは文字起こしの結果を文字起こし出力結果の配列をブロック変数として出力しようとしている
        result.alternatives.map(&:transcript)
        # resultのalternatives配列のtranscript変数だけを呼び出している
        end
        srt_path_return = create_srt(transcripts)
        add_subtitles_to_video(video_path, srt_path_return)
        flash[:success] = "字幕付き動画作成完了"
    end
  end
end

  # -----------------------------------------------------------
  private

  def video_params
    params.require(:video).permit(:title, :video, :open_period, :range, :comment_public, :login_set, :popup_before_video,
      :popup_after_video, { folder_ids: [] }, :data_url)
  end

  def video_search_params
    params.fetch(:search, {}).permit(:title_like, :open_period_from, :open_period_to, :range, :user_name)
  end

  # 共通メソッド(organization::foldersコントローラにも記載)
  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def ensure_user
    if current_user.nil?
      # 修正 遷移先はorganization::foldersコントローラのものとは異なる
      redirect_to root_url, flash: { danger: '権限がありません' }
    end
  end

  # videosコントローラ独自メソッド
  def set_video
    @video = Video.find(params[:id])
  end

  def ensure_admin_or_owner_or_correct_user
    unless current_system_admin.present? || @video.my_upload?(current_user) || current_user.role == 'owner'
      redirect_to video_url, flash: { danger: '権限がありません。' }
    end
  end

  def ensure_my_organization
    if current_user.present?
      # indexへのアクセス制限とshow, eidt, update, destroyへのアクセス制限
      if (@organization.present? && current_user.organization_id != @organization.id) ||
         (@video.present? && @video.user_no_available?(current_user))
        flash[:danger] = '権限がありません。'
        redirect_to videos_url(organization_id: current_user.organization_id)
      end
    elsif current_viewer.present?
      # indexへのアクセス制限とshowへのアクセス制限
      if (@organization.present? && current_viewer.organization_viewers.where(organization_id: @organization.id).empty?) ||
         (@video.present? && current_viewer.organization_viewers.where(organization_id: @video.organization_id).empty?)
        flash[:danger] = '権限がありません'
        redirect_back(fallback_location: root_url)
      end
    end
  end

  def ensure_logged_in_viewer
    if !logged_in? && @video.login_set != false
      redirect_to new_viewer_session_url, flash: { danger: '視聴者ログインしてください。' }
    end
  end

  def ensure_admin_for_access_hidden
    if current_system_admin.nil? && @video.is_valid == false
      flash[:danger] = 'すでに削除された動画です。'
      redirect_back(fallback_location: root_url)
    end
  end

  def set_vimeo_api_token
    @vimeo_api_token = ENV['VIMEO_API_TOKEN']
  end

  def transcribe_audio
    Google::Cloud::Speech.configure { |config| config.credentials = credentials_path.to_s }
    # Google::Cloud::Storage.configure { |config| config.credentials = credentials_path.to_s }
   
    
  end


  
  
  # def add_subtitles_to_video(audio_data, video_file_path, transcript, output_video_path)
  #   begin
  #     File.write(video_file_path, transcript)
  
  #     # Use Open3.capture3 to capture stderr (standard error output)
  #     # command = "ffmpeg -i #{video_file_path} -vf subtitles=#{transcript} -c:a copy -movflags faststart -max_muxing_queue_size 1024 #{output_video_path}"
  #     command = "ffmpeg -i #{video_file_path} -vf subtitles=#{transcript} -c:a copy -movflags faststart #{output_video_path}"
  #     stdout, stderr, status = Open3.capture3(command)
  
  #     if status.success?
  #       puts "add_subtitles_to_video: Successfully added subtitles to the video."
  #     else
  #       puts "add_subtitles_to_video: Failed to add subtitles. Error message: #{stderr}"
  #     end
  #   rescue => e
  #     puts "add_subtitles_to_video でエラーが発生しました: #{e.message}"
  #   end
  # end

  def create_srt(transcripts)
    srt_path = Rails.root.join('public', 'voice', "subtitles#{Time.now.to_i}.srt")
    File.open(srt_path, 'w') do |file|
      transcripts.each_with_index do |transcript, index|
        start_time = format_time(index * 5)
        end_time = format_time((index + 1) * 5)
        file.puts "#{index + 1}"
        file.puts "#{start_time} --> #{end_time}"
        file.puts transcript
        file.puts
      end
    end
    srt_path.to_s
  end

  def add_subtitles_to_video(video_path, srt_path_return)
    escaped_video_path = Shellwords.escape(video_path)
    escaped_srt_path_return = Shellwords.escape(srt_path_return)
    output_video_path = Rails.root.join('public', 'videos', "output_with_subtitles#{Time.now.to_i}.mp4")
    escaped_output_video_path = Shellwords.escape(output_video_path.to_s)
    font_path = Rails.root.join("public/fonts/NotoSansCJK.ttc")
    escape_font_path = Shellwords.escape(font_path.to_s)
    # command = "ffmpeg -i \"#{escaped_video_path}\" -vf \"drawtext=text='#{escaped_srt_path_return}':fontfile=#{font_path}:fontsize=50:fontcolor=black\" -c:a copy \"#{escaped_output_video_path}\""
    command = "ffmpeg -i \"#{escaped_video_path}\" -vf \"subtitles=#{escaped_srt_path_return}:fontfile=#{escape_font_path}:fontsize=50:fontcolor=black\" -c:a copy \"#{escaped_output_video_path}\""
    stdout, stderr, status = Open3.capture3(command)

    puts "FFmpeg command: #{command}"
    puts "FFmpeg stdout: #{stdout}"
    puts "FFmpeg stderr: #{stderr}"

    if status.success?
      puts "Video with subtitles created successfully at #{output_video_path}"
    else
      puts"Failed to create video with subtitles: #{stderr}"
    end
  end



  def format_time(seconds)
    hours = seconds / 3600
    minutes = (seconds % 3600) / 60
    seconds = seconds % 60
    format("%02d:%02d:%02d,000", hours, minutes, seconds)
  end

end
