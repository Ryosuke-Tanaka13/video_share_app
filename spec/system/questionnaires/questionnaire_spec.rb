require 'rails_helper'

RSpec.describe 'アンケート管理機能', type: :system do
  let!(:organization) { create(:organization) }
  let(:user) { create(:user, organization_id: organization.id, confirmed_at: Time.now) }
  let(:valid_pre_video_questionnaire) { '[{"text":"有効な質問", "type":"text", "answers":[], "required":false}]' }
  let(:valid_post_video_questionnaire) { '[{"text":"有効な質問", "type":"text", "answers":[], "required":false}]' }

  before(:each) do
    driven_by(:selenium_chrome_headless)
    sign_in user
  end

  it '新しいアンケートを作成できること' do
    visit new_user_questionnaire_path(user)

    # 質問を追加
    click_button '質問を追加'
    within('.question-field') do
      fill_in '質問', with: 'テスト質問'
    end

    click_button '保存'

    expect(page).to have_content('アンケートが作成されました。')
    expect(Questionnaire.count).to eq(1)
  end

  it 'アンケートを編集できること' do
    questionnaire = user.questionnaires.create!(pre_video_questionnaire: valid_pre_video_questionnaire,
      post_video_questionnaire: valid_post_video_questionnaire)

    visit edit_user_questionnaire_path(user, questionnaire)

    fill_in '質問', with: '編集された質問'
    click_button '保存'

    expect(page).to have_content('アンケートが更新されました。')
    expect(questionnaire.reload.pre_video_questionnaire).to include('編集された質問')
  end

  it 'アンケートを削除できること' do
    user.questionnaires.create!(pre_video_questionnaire: valid_pre_video_questionnaire,
      post_video_questionnaire: valid_post_video_questionnaire)

    visit user_questionnaires_path(user)
    click_link '削除'

    expect(page).to have_content('アンケートが削除されました。')
    expect(Questionnaire.count).to eq(0)
  end
end
