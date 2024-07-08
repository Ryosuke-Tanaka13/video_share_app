FactoryBot.define do
  factory :video_sample, class: 'Video' do
    title { 'サンプルビデオ' }
    open_period { 'Sun, 14 Aug 2022 18:06:00.000000000 JST +09:00' }
    range { false }
    comment_public { false }
    login_set { false }
    popup_before_video { false }
    popup_after_video { false }
    organization_id { 1 }
    user_id { 1 }
    organization
    user
    # vimeoへの動画データのアップロードは行わず。(vimeoに動画データがなくても、data_urlを仮で設定しておけば、アプリ内ではインスタンスが存在可能)
    data_url { '/videos/111111111' }

    # requestsとsystemのdestroyのテスト用に、実際にvimeoに動画データをアップロードする。
    # requestsとsystemのテストまとめて行うと、too many api requests. wait a minute or so, then try again.エラーが生じ、テストに落ちるためコメントアウトしている。(別個にテストを行えば通る)
    # after(:build) do |video_sample|
    #   video = File.open('spec/fixtures/files/rec.webm')
    #   video_client = VimeoMe2::User.new(ENV['VIMEO_API_TOKEN'])
    #   video_data = video_client.upload_video(video)
    #   video_sample.data_url = video_data['uri']
    # end
  end

  factory :video_test, class: 'Video' do
    title { 'テストビデオ' }
    open_period { 'Sun, 14 Aug 2022 18:06:00.000000000 JST +09:00' }
    range { false }
    comment_public { false }
    login_set { false }
    popup_before_video { false }
    popup_after_video { false }
    organization_id { 1 }
    user_id { 3 }
    organization
    user
    # vimeoへの動画データのアップロードは行わず。(vimeoに動画データがなくても、data_urlを仮で設定しておけば、アプリ内ではインスタンスが存在可能)
    data_url { '/videos/222222222' }
  end

  factory :video_popup_before_test, class: 'Video' do
    title { 'テストビデオ1' }
    open_period { 'Sun, 14 Aug 2022 18:06:00.000000000 JST +09:00' }
    range { false }
    comment_public { false }
    login_set { false }
    popup_before_video { true }
    popup_after_video { false }
    organization_id { 1 }
    user_id { 3 }
    organization
    user
    # vimeoへの動画データのアップロードは行わず。(vimeoに動画データがなくても、data_urlを仮で設定しておけば、アプリ内ではインスタンスが存在可能)
    data_url { '/videos/222222222' }
  end

  factory :video_popup_after_test, class: 'Video' do
    title { 'テストビデオ2' }
    open_period { 'Sun, 14 Aug 2022 18:06:00.000000000 JST +09:00' }
    range { false }
    comment_public { false }
    login_set { false }
    popup_before_video { false }
    popup_after_video { true }
    organization_id { 1 }
    user_id { 3 }
    organization
    user
    # vimeoへの動画データのアップロードは行わず。(vimeoに動画データがなくても、data_urlを仮で設定しておけば、アプリ内ではインスタンスが存在可能)
    data_url { '/videos/222222222' }
  end

  factory :video_it, class: 'Video' do
    title { 'ITビデオ' }
    open_period { 'Sun, 14 Aug 2022 18:06:00.000000000 JST +09:00' }
    range { false }
    comment_public { false }
    login_set { true }
    popup_before_video { false }
    popup_after_video { false }
    organization_id { 1 }
    user_id { 1 }
    organization
    user
    # vimeoへの動画データのアップロードは行わず。(vimeoに動画データがなくても、data_urlを仮で設定しておけば、アプリ内ではインスタンスが存在可能)
    data_url { '/videos/333333333' }
  end

  factory :another_video, class: 'Video' do
    title { 'アナザービデオ' }
    open_period { 'Sun, 14 Aug 2022 18:06:00.000000000 JST +09:00' }
    range { false }
    comment_public { false }
    login_set { false }
    popup_before_video { false }
    popup_after_video { false }
    organization_id { 2 }
    user_id { 2 }
    organization
    user
    # vimeoへの動画データのアップロードは行わず。(vimeoに動画データがなくても、data_urlを仮で設定しておけば、アプリ内ではインスタンスが存在可能)
    data_url { '/videos/444444444' }
  end
end
