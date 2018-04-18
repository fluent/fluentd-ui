require 'spec_helper'

class DummyController < ApplicationController; end

describe DummyController do
  controller DummyController do
    skip_before_action :login_required
    def index
      render plain: "Hello World"
    end
  end

  describe '#set_locale' do
    let!(:default_locale) { :en }
    let!(:available_locales) { [:en, :ja] }

    before do
      I18n.stub(:default_locale).and_return(default_locale)
      I18n.stub(:available_locales).and_return(available_locales)

      I18n.locale = I18n.default_locale #initialize
    end

    context 'with params[:lang]' do
      before do
        get 'index', lang: param_lang
      end

      context 'and in available_locales' do
        let(:param_lang) { :ja }

        it 'params[:lang] will be set as locale' do
          expect(I18n.locale).to eq :ja
        end
      end

      context 'and out of available_locales' do
        let(:param_lang) { :ka }

        it 'defalut locale will be set as locale' do
          expect(I18n.locale).to eq default_locale
        end
      end
    end

    context 'with session[:prefer_lang]' do
      before do
        controller.session[:prefer_lang] = :ja
      end

      it 'session[:prefer_lang] will be set as locale' do
        get 'index'
        expect(I18n.locale).to eq :ja
      end
    end

    context 'with request.env["HTTP_ACCEPT_LANGUAGE"]' do
      before do
        request.stub(:env).and_return({ "HTTP_ACCEPT_LANGUAGE" => accept_language })
        get 'index'
      end

      context 'accept_language is available' do
        let(:accept_language) { 'ja' }

        it 'session[:prefer_lang] will be set as locale' do
          expect(I18n.locale).to eq :ja
        end
      end

      context 'accept_language is not available but start with en' do
        let(:accept_language) { 'en-us' }

        it ':en will be set as locale' do
          expect(I18n.locale).to eq :en
        end
      end

      context 'accept_language is not available' do
        let(:accept_language) { 'ka' }

        it 'default_locale will be set as locale' do
          expect(I18n.locale).to eq default_locale
        end
      end
    end
  end
end
