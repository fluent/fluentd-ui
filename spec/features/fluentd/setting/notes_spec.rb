require "spec_helper"

describe "notes", stub: :daemon do
  let!(:exists_user) { build(:user) }
  include_context 'daemon has some config histories'

  before { login_with exists_user }

  describe 'update' do
    let(:note_field) { ".note-content" }
    let(:updating_content) { "This config file is for ..." }

    before do
      visit '/daemon/setting/histories'
      within first("form") do
        first(note_field).set updating_content
        click_button(I18n.t('terms.save'))
      end
    end

    it "update a content of a note" do
      within first("form") do
        first(note_field).value.should eq updating_content
      end
    end
  end
end
