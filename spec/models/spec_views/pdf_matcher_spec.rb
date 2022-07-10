# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SpecViews::PdfMatcher, type: :model do
  let(:status) { 200 }
  let(:expected_status) { :ok }
  let(:headers) { {} }
  let(:actual_file) { scenario }
  let(:body) { File.read(Rails.root.join("public/#{actual_file}.pdf")) }
  let(:dir_name) { scenario }
  let(:test_response) do
    ActionDispatch::TestResponse.new(status, headers, body)
  end
  let(:matcher) do
    SpecViews::PdfMatcher.new(
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
      let(:scenario) { 'pdf_one' }
      it { is_expected.not_to be_a_match }
    end

    context 'when non-default status is expected' do
      let(:status) { 404 }
      let(:expected_status) { :not_found }
      let(:scenario) { 'pdf_one' }
      it { is_expected.to be_a_match }
    end

    context 'when body is new' do
      let(:scenario) { 'pdf_two' }
      it { is_expected.not_to be_a_match }
    end

    context 'when body is known' do
      let(:scenario) { 'pdf_one' }
      it { is_expected.to be_a_match }
    end

    context 'when body is different' do
      let(:scenario) { 'pdf_one' }
      let(:actual_file) { 'pdf_two' }
      it { is_expected.not_to be_a_match }
    end
  end

  describe '#failure_message' do
    subject { matcher.failure_message }

    context 'when status is unexpected' do
      let(:status) { 404 }
      let(:scenario) { 'pdf_one' }
      it { is_expected.to eq 'Unexpected response status 404.' }
    end

    context 'when non-default status is expected' do
      let(:status) { 404 }
      let(:expected_status) { :not_found }
      let(:scenario) { 'pdf_one' }
      it { is_expected.to be_nil }
    end

    context 'when body is new' do
      let(:scenario) { 'pdf_two' }
      it { is_expected.to eq 'PDF has been added.' }
    end

    context 'when body is known' do
      let(:scenario) { 'pdf_one' }
      it { is_expected.to be_nil }
    end

    context 'when body is different' do
      let(:scenario) { 'pdf_one' }
      let(:actual_file) { 'pdf_two' }
      it { is_expected.to eq 'PDF has changed.' }
    end
  end
end
