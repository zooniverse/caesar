require 'rails_helper'

describe ApplicationController do
  describe 'session management' do
    controller(ApplicationController) do
      def index
        render text: 'ok'
      end
    end

    it 'redirects to OAuth login when requested route needs login' do
      get :index
      expect(response).to redirect_to('/auth/zooniverse')
    end
  end
end
