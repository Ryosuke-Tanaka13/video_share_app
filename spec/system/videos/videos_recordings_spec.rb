require 'rails_helper'

RSpec.describe 'Videos::Recordings', type: :system do
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
    Capybara.default_max_wait_time = 20
  end

  after(:each) do
    Capybara.default_max_wait_time = 2
  end

  describe '正常' do
    describe '動画録画ページ' do
      before(:each) do
        login_session(user_owner)
        current_user(user_owner)
        visit new_recording_path
        # MediaDevicesを、ダミーデバイスを取得するコードにオーバーライド
        page.execute_script(<<~JS)
          const script = document.createElement('script');
          script.src = '/js/mocks/MediaDevicesMock.js';
          document.head.appendChild(script);
        JS
      end

      it 'レイアウト' do
        expect(page).to have_button('stream', disabled: false)
        expect(page).to have_select('camera_list', with_options: ['(video)'])
        expect(page).to have_select('mic_list', with_options: ['(audio)'])
        expect(page).to have_button('stop-screen-capture', disabled: true)
        expect(page).to have_button('stop-web-camera', disabled: true)
        expect(page).to have_button('stopBrowserAudio', disabled: true)
        expect(page).to have_button('muteButton', disabled: true)
        expect(page).to have_button('record-button', disabled: true, text: '録画開始')
        expect(page).to have_button('play-button', disabled: true)
        expect(page).to have_button('download-button', disabled: true)
        expect(page).to have_css('canvas[width="640px"][height="360px"]', visible: :visible)
        expect(page).to have_selector('video#web-camera[playsinline][autoplay]', visible: :hidden)
        expect(page).to have_selector('video#screen-capture[autoplay]', visible: :hidden)
        expect(page).to have_selector('video#player-canvas[controls][autoplay][width="640px"][height="360px"]', visible: :hidden)
        expect(page).to have_selector('audio#browser-audio[controls][autoplay][muted]')
        expect(page).to have_selector('audio#mic-audio[controls][autoplay][muted]')
        expect(page).to have_selector('video#recorded-video[playsinline][width="480"][height="270"][loop]')
      end

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
          # デバイス変更前のストリームIDを取得
          old_camera_stream = page.evaluate_script('document.getElementById("web-camera").srcObject.id')
          old_audio_stream = page.evaluate_script('document.getElementById("mic-audio").srcObject.id')
          click_button '選択デバイス反映'
          # getUserMediaで、デバイスIDがvideo_constraintsが渡されたことを確認
          video_user_media = evaluate_script('window.video_user_media')
          expect(video_user_media).to eq(3)
          # デバイス変更後のストリームIDを取得
          new_camera_stream = page.evaluate_script('document.getElementById("web-camera").srcObject.id')
          # デバイスが変更されたことを確認
          expect(new_camera_stream).not_to eq(old_camera_stream)
          # getUserMediaで、デバイスIDがaudio_constraintsが渡されたことを確認
          audio_user_media = evaluate_script('window.audio_user_media')
          expect(audio_user_media).to eq(3)
          new_audio_stream = page.evaluate_script('document.getElementById("mic-audio").srcObject.id')
          expect(old_audio_stream).not_to eq(new_audio_stream)
          # アラートが出ていないことを確認
          expect {
            accept_alert
          }.to raise_error(Capybara::ModalNotFound)
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
          expect(page).to have_css('canvas[style*="display: none;"]', visible: :hidden)
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
          expect {
            accept_alert
          }.to raise_error(Capybara::ModalNotFound)
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
              played = page.evaluate_script('document.getElementById("recorded-video").played.start.length > 0')
              expect(played).to be true
            end

            it 'ダウンロード' do
              click_button 'ダウンロード'
              expect(page).to have_selector('a[style*="display: none;"]', visible: :hidden)
              # 動画のURLが生成されたことを確認
              video_url = page.evaluate_script('document.getElementById("download-link").href')
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
      before(:each) do
        login_session(user_owner)
        current_user(user_owner)
        visit new_recording_path
      end

      context 'デバイス取得時にエラー' do
        before(:each) do
          # MediaDevicesをデバイス取得が失敗するコードにオーバーライド
          page.execute_script(<<~JS)
            const script = document.createElement('script');
            script.src = '/js/mocks/MediaDevicesMockError.js';
            document.head.appendChild(script);
          JS
        end

        it 'デバイス取得失敗' do
          click_button 'デバイス取得'
          expect(page.driver.browser.switch_to.alert.text).to eq 'デバイスの取得に失敗しました。'
          page.driver.browser.switch_to.alert.accept
          expect(page.driver.browser.switch_to.alert.text).to eq 'webカメラを取得できませんでした。'
          page.driver.browser.switch_to.alert.accept
          expect(page.driver.browser.switch_to.alert.text).to eq '画面キャプチャを取得できませんでした。'
          page.driver.browser.switch_to.alert.accept
          expect(page.driver.browser.switch_to.alert.text).to eq 'マイク音声を取得できませんでした。'
          page.driver.browser.switch_to.alert.accept
          # ストリームが関連付けられていないことを確認
          video_stream_null = page.evaluate_script('document.getElementById("web-camera").srcObject === null')
          expect(video_stream_null).to be true
          audio_stream_null = page.evaluate_script('document.getElementById("mic-audio").srcObject === null')
          expect(audio_stream_null).to be true
          # セレクトボックスにデバイスが登録されていないことを確認
          camera_list = page.evaluate_script('document.getElementById("camera_list").innerHTML === ""')
          expect(camera_list).to be true
          mic_list = page.evaluate_script('document.getElementById("mic_list").innerHTML === ""')
          expect(mic_list).to be true
          expect(page).to have_button('選択デバイス反映', disabled: true)
        end

        it '録画開始失敗' do
          click_button 'デバイス取得'
          page.driver.browser.switch_to.alert.accept
          page.driver.browser.switch_to.alert.accept
          page.driver.browser.switch_to.alert.accept
          page.driver.browser.switch_to.alert.accept
          click_button '録画開始'
          expect(page.driver.browser.switch_to.alert.text).to eq '録画デバイスを反映してください。'
          page.driver.browser.switch_to.alert.accept
          expect(page).to have_button('録画開始', disabled: false)
        end
      end

      context 'デバイス取得成功時' do
        before(:each) do
          # デバイス取得時にダミーストリームを渡す。
          page.execute_script(<<~JS)
            const script = document.createElement('script');
            script.src = '/js/mocks/MediaDevicesMock.js';
            document.head.appendChild(script);
          JS
          click_button 'デバイス取得'
        end

        it '選択デバイス反映失敗' do
          # 選択デバイス反映時にエラーを発生させる。
          page.execute_script(<<~JS)
            const script = document.createElement('script');
            script.src = '/js/mocks/MediaDevicesMockError.js';
            document.head.appendChild(script);
          JS
          old_camera_stream = page.evaluate_script('document.getElementById("web-camera").srcObject.id')
          old_audio_stream = page.evaluate_script('document.getElementById("mic-audio").srcObject.id')
          click_button '選択デバイス反映'
          expect(page.driver.browser.switch_to.alert.text).to eq 'カメラの変更に失敗しました。'
          page.driver.browser.switch_to.alert.accept
          expect(page.driver.browser.switch_to.alert.text).to eq 'マイクの変更に失敗しました。'
          page.driver.browser.switch_to.alert.accept
          # ストリームが更新されていないことを確認
          new_camera_stream = page.evaluate_script('document.getElementById("web-camera").srcObject.id')
          expect(old_camera_stream).to eq(new_camera_stream)
          new_audio_stream = page.evaluate_script('document.getElementById("mic-audio").srcObject.id')
          expect(old_audio_stream).to eq(new_audio_stream)
        end

        it '録画開始失敗、MediaRecorderオブジェクト生成失敗時' do
          page.execute_script(<<~JS)
            // MediaRecorderがエラーとなるコードに置き換える
            window.MediaRecorder = function(ms, options) {
              throw new Error('Mocked MediaRecorder constructor error');
            };
          JS
          click_button '録画開始'
          expect(page.driver.browser.switch_to.alert.text).to eq 'Exception while creating MediaRecorder: Mocked MediaRecorder constructor error'
          page.driver.browser.switch_to.alert.accept
          expect(page).to have_button('録画開始', disabled: false)
        end

        it '録画開始失敗、startメソッドエラー' do
          page.execute_script(<<~JS)
            // MediaRecorderのstartメソッドを、エラーが発生するコードに置き換える
            MediaRecorder.prototype.start = function(timeslice) {
              throw new Error('Mocked MediaRecorder start error');
            };
          JS
          click_button '録画開始'
          expect(page.driver.browser.switch_to.alert.text).to eq 'error record Mocked MediaRecorder start error'
          page.driver.browser.switch_to.alert.accept
          expect(page).to have_button('録画開始', disabled: false)
        end
      end
    end
  end
end
