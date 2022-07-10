class SpecViews::HtmlMatcher
  attr_reader :response, :directory, :failure_message
  delegate :champion_html, to: :directory

  def initialize(response, dir_name, run_time:, expected_status: :ok)
    @response = response
    @directory = SpecViews::Directory.for_dir_name(dir_name)
    @status_match = response_status_match?(response, expected_status)
    @match = @status_match && challenger_html == champion_html
    @directory.write_last_run(run_time)
    return if match?

    @failure_message = 'View has changed.'
    @failure_message = 'View has been added.' if champion_html.nil?
    @failure_message = "Unexpected response status #{response.status}." unless status_match?
    @directory.write_challenger(challenger_html) if status_match?
  end

  def match?
    @match
  end

  def status_match?
    @status_match
  end

  private

  def challenger_html
    sanitized_body
  end

  def response_status_match?(response, expected_status)
    response.status == expected_status ||
      response.message.parameterize.underscore == expected_status.to_s
  end

  def sanitized_body
    remove_pack_digests_from_body(remove_digests_from_body(body))
  end

  def body
    response.body
  end

  def remove_digests_from_body(body)
    body.gsub(/(-[a-z0-9]{64})(\.css|\.js|\.ico|\.png|\.jpg|\.jpeg|\.svg|\.gif)/, '\2')
  end

  def remove_pack_digests_from_body(body)
    body.gsub(%r{(packs.*/js/[a-z0-9_]+)(-[a-z0-9]{20})(\.js)}, '\1\3')
  end
end
