# frozen_string_literal: true

module SpecViews
  class BaseMatcher
    attr_reader :response, :directory, :failure_message, :sanitizer, :type

    delegate :champion_html, to: :directory

    def initialize(response, description, run_time:, expected_status: :ok, sanitizer: nil, type: :request)
      @response = response
      @type = type
      @sanitizer = sanitizer
      @extractor = extractor_class.new(response, expected_status: expected_status)
      @directory = SpecViews::Directory.for_description(description, content_type: content_type)
      @extractor_failure = @extractor.extractor_failure?
      @match = !extractor_failure? && match_challenger
      directory.write_last_run(run_time) if champion_html
      return if match?

      if extractor_failure?
        @failure_message = @extractor.failure_message
        return
      end

      @failure_message = "#{subject_name} has changed."
      @failure_message = "#{subject_name} has been added." if champion_html.nil?

      if ENV["SPEC_VIEWS_DEBUG_OUTPUT"]
        puts "====DEBUG===: #{description}"
        p challenger_body
        puts "====DEBUGEND===: #{description}"
      end

      directory.write_last_run(run_time)
      directory.write_meta(description, type, content_type)
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
