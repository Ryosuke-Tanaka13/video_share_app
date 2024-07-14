require 'rails_helper'

RSpec.describe 'QuestionnaireAnswers', type: :system, js: true do
  let(:user_owner) { create(:user_owner, confirmed_at: Time.now) }
  let(:viewer) { create(:viewer, confirmed_at: Time.now) }
  let(:video) { create(:video, user: user_owner) }
  let(:required_questionnaire_item) { create(:questionnaire_item, video: video, required: true, pre_question_text: '必須質問') }
  let(:optional_questionnaire_item) { create(:questionnaire_item, video: video, required: false, pre_question_text: '任意質問') }

  let!(:questionnaire_answer) { create(:questionnaire_answer, video: video, questionnaire_item: required_questionnaire_item, viewer: viewer) }

  before do
    sign_in viewer
  end

  describe 'アンケートの表示と回答' do
    context '必須質問が未回答の場合' do
      it 'エラーメッセージが表示され、質問フォームが再表示される' do
        visit video_path(video)
        find('button.play-video').click
        fill_in "questionnaire_answer[pre_answers][#{required_questionnaire_item.id}]", with: ''
        click_button '送信'
        expect(page).to have_content('回答に不備があります。※は必須項目です。')
      end
    end

    context '回答が正常に保存される場合' do
      it '正常に保存される' do
        visit video_path(video)
        find('button.play-video').click
        fill_in "questionnaire_answer[pre_answers][#{required_questionnaire_item.id}]", with: '有効な回答'
        click_button '送信'
        expect(page).to have_content('回答が送信されました。')
      end
    end

    context '任意質問が未回答の場合' do
      it '空の状態でも保存可能である' do
        visit video_path(video)
        find('button.play-video').click
        fill_in "questionnaire_answer[pre_answers][#{optional_questionnaire_item.id}]", with: ''
        click_button '送信'
        expect(page).to have_content('回答が送信されました。')
      end
    end

    context '不正なパラメータが送信された場合' do
      it 'エラーメッセージが表示され、リダイレクトされる' do
        visit video_path(video)
        find('button.play-video').click
        fill_in "questionnaire_answer[pre_answers][999]", with: '不正な回答'
        click_button '送信'
        expect(page).to have_content('Questionnaire item not found')
      end
    end
  end

  describe '回答の削除' do
    context '回答の削除が成功する場合' do
      it '回答が削除され、成功メッセージが表示される' do
        visit video_questionnaire_answers_path(video)
        accept_confirm do
          click_link '削除', href: video_questionnaire_answer_path(video, questionnaire_answer)
        end
        expect(page).to have_content('回答が削除されました。')
      end
    end

    context '回答の削除が失敗する場合' do
      before do
        allow_any_instance_of(QuestionnaireAnswer).to receive(:destroy).and_return(false)
      end

      it '回答が削除されず、エラーメッセージが表示される' do
        visit video_questionnaire_answers_path(video)
        accept_confirm do
          click_link '削除', href: video_questionnaire_answer_path(video, questionnaire_answer)
        end
        expect(page).to have_content('回答の削除に失敗しました。')
      end
    end
  end

  describe 'アンケートの表示と回答の確認' do
    before do
      sign_in user_owner
      video.update(pre_video_questionnaire_id: required_questionnaire_item.id)
    end

    it '視聴者が動画視聴前のアンケートに回答し、投稿者がその回答を確認できる' do
      # 視聴者としてサインイン
      sign_out user_owner
      sign_in viewer

      # 動画視聴ページに移動
      visit video_path(video)

      # 動画再生ボタンをクリックしてポップアップを表示
      find('button.play-video').click

      # 動画再生前のアンケートポップアップが表示されることを確認
      within('#popup-before') do
        expect(page).to have_content(required_questionnaire_item.pre_question_text)

        # アンケートに回答し送信
        fill_in "questionnaire_answer[pre_answers][#{required_questionnaire_item.id}]", with: '回答テスト'
        click_button '送信'
      end

      # 回答が送信されたことを確認
      expect(page).to have_content('回答が送信されました。')

      # 動画投稿者として再度サインイン
      sign_out viewer
      sign_in user_owner

      # 動画詳細ページに移動
      visit video_path(video)

      # 回答一覧ページに移動
      click_link '回答一覧'

      # 回答が表示されていることを確認
      expect(page).to have_content('回答テスト')
    end
  end
end
