# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SpecViews::MailMessageExtractor do
  it 'extracts the body of a mail' do
    extractor = described_class.new(NotificationMailer.signup, expected_status: :ok)
    expect(extractor.body).to include('<h1>Welcome</h1>')
    expect(extractor).not_to be_extractor_failure
  end

  it 'fails for objects without body or parts' do
    extractor = described_class.new(Object.new, expected_status: :ok)
    expect(extractor.body).to be_nil
    expect(extractor.failure_message).to eq 'Failed to find mail part'
  end
end
