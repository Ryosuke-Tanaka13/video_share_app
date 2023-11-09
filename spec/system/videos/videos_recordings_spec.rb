require 'rails_helper'

RSpec.describe "Videos::Recordings", type: :system do
  let(:system_admin) { create(:system_admin, confirmed_at: Time.now) }
  let(:organization) { create(:organization) }
  let(:user_owner) { create(:user_owner, organization_id: organization.id, confirmed_at: Time.now) }
  let(:user_staff) { create(:user_staff, organization_id: organization.id, confirmed_at: Time.now) }
  let(:viewer) { create(:viewer, confirmed_at: Time.now) }

  before(:each) do
    system_admin
    organization
    user_owner
    user_staff
    viewer
  end

  describe '正常' do
    before(:each) do
      Capybara.default_max_wait_time = 10
      login_session(user_owner)
      current_user(user_owner)
      visit new_recording_path
      # ダミーデバイス取得用の関数をオーバーライド
      page.execute_script(<<~JS)
        const script = document.createElement('script');
        script.src = '/js/mocks/MediaDevicesMock.js';
        document.head.appendChild(script);
      JS
    end

    after do
      Capybara.default_max_wait_time = 2
    end

    # it 'レイアウト' do
    #   expect(page).to have_button('stream', disabled: false)
    #   expect(page).to have_select('camera_list', with_options: ['(video)'])
    #   expect(page).to have_select('mic_list', with_options: ['(audio)'])
    #   expect(page).to have_button('stop-screen-capture', disabled: true)
    #   expect(page).to have_button('stop-web-camera', disabled: true)
    #   expect(page).to have_button('stopBrowserAudio', disabled: true)
    #   expect(page).to have_button('muteButton', disabled: true)
    #   expect(page).to have_button('record-button', disabled: true, text: '録画開始')
    #   expect(page).to have_button('play-button', disabled: true)
    #   expect(page).to have_button('download-button', disabled: true)
    #   expect(page).to have_css('canvas[width="640px"][height="360px"]', visible: true)
    #   expect(page).to have_selector('video#web-camera[playsinline][autoplay]', visible: false)
    #   expect(page).to have_selector('video#screen-capture[autoplay]', visible: false)
    #   expect(page).to have_selector('video#player-canvas[controls][autoplay][width="640px"][height="360px"]', visible: false)
    #   expect(page).to have_selector('audio#browser-audio[controls][autoplay][muted]')
    #   expect(page).to have_selector('audio#mic-audio[controls][autoplay][muted]')
    #   expect(page).to have_selector('video#recorded-video[playsinline][width="480"][height="270"][loop]')
    # end

    describe '動画録画ページ' do
      it 'デバイス取得' do
        click_button 'デバイス取得'
        video_device = evaluate_script('document.getElementById("camera_list").getElementsByTagName("option")[0].innerHTML === "ダミーのビデオデバイス1(videoDevice1)"')
        expect(video_device).to be true
        expect(page).to have_select('camera_list', with_options: ['ダミーのビデオデバイス2(videoDevice2)'])
        audio_device = evaluate_script('document.getElementById("mic_list").getElementsByTagName("option")[0].innerHTML === "ダミーのオーディオデバイス1(audioDevice1)"')
        expect(audio_device).to be true
        expect(page).to have_select('mic_list', with_options: ['ダミーのオーディオデバイス2(audioDevice2)'])
        expect(page).to have_button('stop-screen-capture', disabled: false)
        expect(page).to have_button('stop-web-camera', disabled: false)
        expect(page).to have_button('stopBrowserAudio', disabled: false)
        expect(page).to have_button('muteButton', disabled: false)
        expect(page).to have_button('record-button', disabled: false, text: '録画開始')
        expect(page).to have_button('play-button', disabled: true)
        expect(page).to have_button('download-button', disabled: true)
        expect(page).to have_css('canvas[style*="display: block;"]')
        # getUserMediaで、デバイスIDが無い場合のメソッドが実行されたことを確認
        video_user_media = evaluate_script('window.video_user_media')
        expect(video_user_media).to eq(1)
        audio_user_media = evaluate_script('window.audio_user_media')
        expect(audio_user_media).to eq(1)
        # ダミーのwebカメラストリームが関連付けてあることを確認
        camera_stream_exists = page.evaluate_script('document.getElementById("web-camera").srcObject.active')
        expect(camera_stream_exists).to be true
        # ダミーのスクリーンキャプチャストリームが関連付けてあることを確認
        screen_stream_exists = page.evaluate_script('document.getElementById("screen-capture").srcObject.active')
        expect(screen_stream_exists).to be true
        # 映像を合成してキャンバスに出力されていることを確認
        canvas_stream_exists = page.evaluate_script('document.getElementById("player-canvas").srcObject.active')
        expect(canvas_stream_exists).to be true
        # ダミーのブラウザ音声ストリームが関連付けてあることを確認
        browser_audio_stream_exists = page.evaluate_script('document.getElementById("browser-audio").srcObject.active')
        expect(browser_audio_stream_exists).to be true
        # ダミーのマイク音声ストリームが関連付けてあることを確認
        mic_audio_stream_exists = page.evaluate_script('document.getElementById("mic-audio").srcObject.active')
        expect(mic_audio_stream_exists).to be true
      end

      context 'デバイス取得後' do
        before(:each) do
          click_button 'デバイス取得'
          # stopメソッドが呼び出された回数をカウント
          execute_script('window.stopCalled = 0; MediaStreamTrack.prototype._stop = MediaStreamTrack.prototype.stop; MediaStreamTrack.prototype.stop = function(){ window.stopCalled++; this._stop(); };')
        end

        it '選択デバイス反映' do
          # 2つ目のデバイスを選択
          select('ダミーのビデオデバイス2(videoDevice2)', from: 'camera_list')
          execute_script('window.camList = document.getElementById("camera_list")')
          video_device = evaluate_script('camList.getElementsByTagName("option")[camList.selectedIndex].innerHTML === "ダミーのビデオデバイス2(videoDevice2)"')
          expect(video_device).to be true
          select('ダミーのオーディオデバイス2(audioDevice2)', from: 'mic_list')
          execute_script('window.micList = document.getElementById("mic_list")')
          audiio_device = evaluate_script('micList.getElementsByTagName("option")[micList.selectedIndex].innerHTML === "ダミーのオーディオデバイス2(audioDevice2)"')
          expect(audiio_device).to be true
          click_button '選択デバイス反映'
          # getUserMediaで、デバイスIDがある場合のメソッドが実行されたことを確認 -> デバイス変更の確認
          video_user_media = evaluate_script('window.video_user_media')
          expect(video_user_media).to eq(3)
          audio_user_media = evaluate_script('window.audio_user_media')
          expect(audio_user_media).to eq(3)
        end

        it '画面キャプチャを停止' do
          click_button '画面キャプチャを停止'
          expect(page).to have_button('stop-screen-capture', disabled: true)
          # 映像トラックを停止するメソッドが実行された回数を確認
          stop_called = evaluate_script('window.stopCalled')
          expect(stop_called).to eq(1)
          # ダミーのビデオストリームの関連付けが解除されていること確認
          video_stream_null = page.evaluate_script('document.getElementById("screen-capture").srcObject === null')
          expect(video_stream_null).to be true
        end

        it 'webカメラを停止' do
          click_button 'webカメラを停止'
          expect(page).to have_button('stop-web-camera', disabled: true)
          # トラックを停止するメソッドが実行された回数を確認
          stop_called = evaluate_script('window.stopCalled')
          expect(stop_called).to be > 0
          # ダミーのビデオストリームの関連付けが解除されていること確認
          video_stream_null = page.evaluate_script('document.getElementById("web-camera").srcObject === null')
          expect(video_stream_null).to be true
        end

        it '画面キャプチャ、webカメラを停止' do
          click_button 'webカメラを停止'
          click_button '画面キャプチャを停止'
          expect(page).to have_css('canvas[style*="display: none;"]', visible: false)
        end

        it 'ブラウザ音声を削除' do
          click_button 'ブラウザ音声を削除'
          expect(page).to have_button('stopBrowserAudio', disabled: true)
          # トラックを停止するメソッドが実行された回数を確認
          stop_called = evaluate_script('window.stopCalled')
          expect(stop_called).to eq(1)
          # ダミーのオーディオストリームの関連付けが解除されていること確認
          audio_stream_null = page.evaluate_script('document.getElementById("browser-audio").srcObject === null')
          expect(audio_stream_null).to be true
        end

        it 'マイク音声を削除' do
          click_button 'マイク音声を削除'
          expect(page).to have_button('muteButton', disabled: true)
          # トラックを停止するメソッドが実行された回数を確認
          stop_called = evaluate_script('window.stopCalled')
          expect(stop_called).to eq(1)
          # ダミーのオーディオストリームの関連付けが解除されていること確認
          audio_stream_null = page.evaluate_script('document.getElementById("mic-audio").srcObject === null')
          expect(audio_stream_null).to be true
        end

        it '録画開始' do
          click_button '録画開始'
          expect(page).to have_button('record-button', disabled: false, text: '録画停止')
        end

        context '録画開始後' do
          before(:each) do
            click_button '録画開始'
          end

          it '録画停止' do
            click_button '録画停止'
            expect(page).to have_button('録画開始', disabled: false)
            expect(page).to have_button('再生', disabled: false)
            expect(page).to have_button('再生', disabled: false)
          end

          context '録画停止後' do
            before(:each) do
              click_button '録画停止'
            end

            it '再生' do
              click_button '再生'
              # 動画のURLが生成されたことを確認
              video_url = page.evaluate_script('document.getElementById("recorded-video").src')
              expect(video_url).to start_with('blob:')
              # 再生されているか確認
              played = page.evaluate_script("document.getElementById('recorded-video').played.start.length > 0")
              expect(played).to be true
            end

            it 'ダウンロード' do
              click_button 'ダウンロード'
              expect(page).to have_selector('a[style*="display: none;"]', visible: false)
              # 動画のURLが生成されたことを確認
              video_url = page.evaluate_script("document.getElementById('download-link').href")
              expect(video_url).to start_with('blob:')
              # 指定された場所にダウンロードされたことを確認
              expect(File).to exist(Rails.root.join('tmp', 'rec.webm'))
              clear_downloads
            end
          end
        end
      end
    end
  end

  describe '異常' do
    describe '動画録画ページ' do
      # console.errorの部分
    end
  end
end
