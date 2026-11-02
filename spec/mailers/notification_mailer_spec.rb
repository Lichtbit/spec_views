# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NotificationMailer, type: :mailer do
  describe '#signup' do
    it 'renders the body' do
      expect(described_class.signup).to match_html_fixture
    end
  end
end
