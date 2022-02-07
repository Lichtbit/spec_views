# frozen_string_literal: true

require "timecop"

module SpecViews
  module Support
    class SpecView
      attr_reader :body, :context, :example, :spec_name, :directory_path, :last_run_path,
                  :time, :response

      class ReadError < StandardError
        def initialize(msg = 'My default message')
          super
        end
      end

      def initialize(context, example, response, time)
        @context = context
        @response = response
        @example = example
        @spec_name = example.full_description.strip
                            .gsub(/[^0-9A-Za-z.\-]/, '_').gsub('__', '_')
        @spec_name = "#{@spec_name}__pdf" if pdf?
        @directory_path = Rails.root.join(Rails.configuration.spec_views.directory, spec_name)
        @last_run_path = directory_path.join('last_run.txt')
        @body = response.body
        @time = time
      end

      def write
        FileUtils.mkdir_p(directory_path)
        write_to_path(champion_path, sanitized_body)
        put_write_instructions
      end

      def write_challenger
        return unless changed?

        FileUtils.mkdir_p(directory_path)
        write_to_path(challenger_path, sanitized_body)
      end

      def delete_challenger
        FileUtils.rm_f(challenger_path) unless changed?
      end

      def write_last_run
        FileUtils.mkdir_p(directory_path)
        write_to_path(last_run_path, time)
      end

      def expect_eq
        pdf? ? expect_eq_pdf : expect_eq_text
        delete_challenger
      end

      def expect_eq_text
        context.expect(sanitized_body).to context.eq(read)
      end

      def expect_eq_pdf
        champion_md5 = nil
        begin
          champion_md5 = Digest::MD5.file(champion_path).hexdigest
        rescue Errno::ENOENT # rubocop:disable Lint/SuppressedException
        end
        current_md5 = Digest::MD5.hexdigest(sanitized_body)
        context.expect(current_md5).to context.eq(champion_md5), 'MD5s of PDF do not match'
      end

      def read
        File.read(champion_path)
      rescue Errno::ENOENT
        raise ReadError, "Cannot find view fixture #{champion_path.to_s.gsub(Rails.root.to_s, '')}\n" \
        "Create the file by adding the follwing to your spec:\n" \
        'spec_view.write'
      end

      def changed?
        return pdf_changed? if pdf?

        begin
          champion = read
        rescue ReadError
          champion = nil
        end
        sanitized_body != champion
      end

      def pdf_changed?
        champion_md5 = Digest::MD5.file(champion_path).hexdigest
        current_md5 = Digest::MD5.hexdigest(sanitized_body)
        champion_md5 != current_md5
      rescue Errno::ENOENT
        true
      end

      private

      def champion_path
        pdf? ? directory_path.join('view.pdf') : directory_path.join('view.html')
      end

      def challenger_path
        pdf? ? directory_path.join('challenger.pdf') : directory_path.join('challenger.html')
      end

      def sanitized_body
        return remove_headers_from_pdf(body) if pdf?

        remove_pack_digests_from_body(
          remove_digests_from_body(body),
        )
      end

      def remove_digests_from_body(body)
        body.gsub(/(-[a-z0-9]{64})(\.css|\.js|\.ico|\.png|\.jpg|\.jpeg|\.svg|\.gif)/, '\2')
      end

      def remove_pack_digests_from_body(body)
        body.gsub(%r{(packs.*/js/[a-z0-9_]+)(-[a-z0-9]{20})(\.js)}, '\1\3')
      end

      def remove_headers_from_pdf(pdf)
        pdf
          .force_encoding("BINARY")
          .gsub(/^\/CreationDate \(.*\)$/, '')
          .gsub(/^\/ModDate \(.*\)$/, '')
          .gsub(/^\/ID \[<.+><.+>\]$/, '')
      end

      def put_write_instructions
        puts
        puts "\e[33mWarning:\e[0m Writing view fixture to #{champion_path.to_s.gsub(Rails.root.to_s, '')}"
        puts 'xdg-open "http://localhost:3100/spec_views/"'
      end

      def write_to_path(path, content)
        File.open(path.to_s, pdf? ? 'wb' : 'w') do |file|
          file.write(content)
        end
      end

      def pdf?
        response.content_type == 'application/pdf'
      end
    end

    def spec_view
      SpecView.new(self, @_spec_view_example, response, $_spec_view_time)
    end

    module SpecViewExample
      def render(description = nil, focus: nil, pending: nil, status: :ok, &block)
        context do # rubocop:disable RSpec/MissingExampleGroupArgument
          render_views
          options = {}
          options[:focus] = focus unless focus.nil?
          options[:pending] = pending unless pending.nil?
          it(description, options) do
            instance_eval(&block)
            spec_view.write_last_run
            write = status.in?(
              [
                response.message.parameterize.underscore.to_sym,
                response.status,
              ],
            )
            spec_view.write_challenger if write
            spec_view.expect_eq
          end
        end
      end
    end

    RSpec.configure do |c|
      c.extend SpecViewExample, type: :controller
      c.before(:suite) do |_example|
        $_spec_view_time = Time.zone.now
      end
      c.before(type: :controller) do |example|
        @_spec_view_example = example
      end
      c.before(:each, type: :controller) do
        Timecop.freeze(Time.zone.local(2024, 2, 29, 0o0, 17, 42))
      end
      c.after(:each, type: :controller) do
        Timecop.return
      end
    end
  end
end

RSpec.configure do |rspec|
  rspec.include SpecViews::Support, type: :controller
end
