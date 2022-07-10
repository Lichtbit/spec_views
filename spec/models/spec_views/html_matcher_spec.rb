require 'rails_helper'

RSpec.describe SpecViews::HtmlMatcher, type: :model do
  let(:status) { 200 }
  let(:expected_status) { :ok }
  let(:headers) { {} }
  let(:body) { "<h1>#{scenario}</h1>" }
  let(:dir_name) { scenario }
  let(:test_response) do
    ActionDispatch::TestResponse.new(status, headers, body)
  end
  let(:matcher) do
    SpecViews::HtmlMatcher.new(
      test_response,
      dir_name,
      expected_status: expected_status,
      run_time: Time.current
    )
  end

  describe '#matches?' do
    subject { matcher }

    context 'when status is unexpected' do
      let(:status) { 404 }
      let(:scenario) { 'known_content' }
      it { is_expected.not_to be_a_match }
    end

    context 'when non-default status is expected' do
      let(:status) { 404 }
      let(:expected_status) { :not_found }
      let(:scenario) { 'known_content' }
      it { is_expected.to be_a_match }
    end

    context 'when body is new' do
      let(:scenario) { 'new_content' }
      it { is_expected.not_to be_a_match }
    end

    context 'when body is known' do
      let(:scenario) { 'known_content' }
      it { is_expected.to be_a_match }
    end

    context 'when body is different' do
      let(:scenario) { 'known_content' }
      let(:body) { '<h1>different content</h1>' }
      it { is_expected.not_to be_a_match }
    end
  end

  describe '#failure_message' do
    subject { matcher.failure_message }

    context 'when status is unexpected' do
      let(:status) { 404 }
      let(:scenario) { 'known_content' }
      it { is_expected.to eq 'Unexpected response status 404.' }
    end

    context 'when non-default status is expected' do
      let(:status) { 404 }
      let(:expected_status) { :not_found }
      let(:scenario) { 'known_content' }
      it { is_expected.to be_nil }
    end

    context 'when body is new' do
      let(:scenario) { 'new_content' }
      it { is_expected.to eq 'View has been added.' }
    end

    context 'when body is known' do
      let(:scenario) { 'known_content' }
      it { is_expected.to be_nil }
    end

    context 'when body is different' do
      let(:scenario) { 'known_content' }
      let(:body) { '<h1>different content</h1>' }
      it { is_expected.to eq 'View has changed.' }
    end
  end
end
