# frozen_string_literal: true

module SpecViews
  class BaseMatcher
    attr_reader :response, :directory, :failure_message

    delegate :champion_html, to: :directory

    def initialize(response, description, run_time:, expected_status: :ok)
      @response = response
      @extractor = HttpResponseExtractor.new(response, expected_status: expected_status)
      @directory = SpecViews::Directory.for_description(description, content_type: content_type)
      @extractor_failure = @extractor.extractor_failure?
      @match = @extractor_failure && match_challenger
      @directory.write_last_run(run_time)
      return if match?

      @failure_message = "#{subject_name} has changed."
      @failure_message = "#{subject_name} has been added." if champion_html.nil?
      @failure_message = @extractor.failure_message unless extractor_failure?
      return unless extractor_failure?

      @directory.write_description(description)
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
  end
end
