# frozen_string_literal: true

module SpecViews
  class BaseMatcher
    attr_reader :response, :directory, :failure_message, :type

    delegate :champion_html, to: :directory

    def initialize(response, description, run_time:, expected_status: :ok, type: :request)
      @response = response
      @type = type
      @extractor = extractor_class.new(response, expected_status: expected_status)
      @directory = SpecViews::Directory.for_description(description, content_type: content_type)
      @extractor_failure = @extractor.extractor_failure?
      @match = !extractor_failure? && match_challenger
      directory.write_meta(description, run_time, type, content_type) if champion_html
      return if match?

      if extractor_failure?
        @failure_message = @extractor.failure_message
        return
      end

      @failure_message = "#{subject_name} has changed."
      @failure_message = "#{subject_name} has been added." if champion_html.nil?

      directory.write_meta(description, run_time, type, content_type)
      @directory.write_challenger(challenger_body)
    end

    def match?
      @match
    end

    def extractor_failure?
      @extractor_failure
    end

    protected

    def subject_name
      raise NotImplementedError
    end

    def challenger_body
      raise NotImplementedError
    end

    def match_challenger
      raise NotImplementedError
    end

    def content_type
      raise NotImplementedError
    end

    def extractor_class
      return CapybaraSessionExtractor if type == :feature
      return MailMessageExtractor if type == :mailer

      HttpResponseExtractor
    end
  end
end
