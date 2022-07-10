class SpecViews::PdfMatcher
  attr_reader :response, :directory, :failure_message

  def initialize(response, dir_name, run_time:, expected_status: :ok)
    @response = response
    @directory = SpecViews::Directory.for_dir_name(dir_name, content_type: :pdf)
    @status_match = response_status_match?(response, expected_status)
    @match = @status_match && champion_hash == challenger_hash
    @directory.write_last_run(run_time)
    return if match?

    @failure_message = 'PDF has changed.'
    @failure_message = 'PDF has been added.' if champion_hash.nil?
    @failure_message = "Unexpected response status #{response.status}." unless status_match?
    @directory.write_challenger(sanitized_body) if status_match?
  end

  def match?
    @match
  end

  def status_match?
    @status_match
  end

  private

  def champion_hash
    @champion_hash ||= begin
      Digest::MD5.file(directory.champion_path).hexdigest
    rescue Errno::ENOENT # rubocop:disable Lint/SuppressedException
      nil
    end
  end

  def challenger_hash
    @challenger_hash ||= Digest::MD5.hexdigest(sanitized_body)
  end

  def response_status_match?(response, expected_status)
    response.status == expected_status ||
      response.message.parameterize.underscore == expected_status.to_s
  end

  def sanitized_body
    @sanitized_body ||= remove_headers_from_pdf(body)
  end

  def body
    response.body
  end

  def remove_headers_from_pdf(body)
    body
      .force_encoding("BINARY")
      .gsub(/^\/CreationDate \(.*\)$/, '')
      .gsub(/^\/ModDate \(.*\)$/, '')
      .gsub(/^\/ID \[<.+><.+>\]$/, '')
  end
end
