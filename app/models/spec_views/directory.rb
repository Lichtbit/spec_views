# frozen_string_literal: true

module SpecViews
  class Directory
    attr_reader :path

    def self.for_description(description, content_type: :html)
      dir_name = description.strip.gsub(/[^0-9A-Za-z.-]/, '_').gsub('__', '_')
      new(Rails.root.join(Rails.configuration.spec_views.directory, dir_name), content_type)
    end

    def initialize(path, content_type = nil)
      @path = path
      @content_type = ActiveSupport::StringInquirer.new(content_type.to_s) if content_type
    end

    def basename
      path.basename
    end

    def to_param
      basename.to_s
    end

    def name
      basename
    end

    def controller_name
      splitted_description.first.gsub(/Controller(_.*)$/, 'Controller').gsub(/Controller$/, '').gsub('_', '::')
    end

    def method
      splitted_description.second[0, 4]
    end

    def description_tail
      splitted_description.third
    end

    def delete!
      FileUtils.remove_dir(path)
    end

    def champion_path
      path.join("view.#{file_extension}")
    end

    def champion?
      File.file?(champion_path)
    end

    def champion_html
      File.read(champion_path)
    rescue Errno::ENOENT
      nil
    end

    def write_champion(content)
      FileUtils.mkdir_p(path)
      File.open(champion_path, binary? ? 'wb' : 'w') { |f| f.write(content) }
    end

    def challenger_path
      path.join("challenger.#{file_extension}")
    end

    def challenger?
      File.file?(challenger_path)
    end

    def challenger_html
      File.read(challenger_path)
    rescue Errno::ENOENT
      nil
    end

    def write_challenger(content)
      FileUtils.mkdir_p(path)
      File.open(challenger_path, binary? ? 'wb' : 'w') { |f| f.write(content) }
    end

    def remove_challenger
      FileUtils.remove_file(challenger_path)
    end

    def meta_path
      path.join('meta.txt')
    end

    def write_meta(description, spec_type, content_type)
      FileUtils.mkdir_p(path)
      lines = [
        description.to_s.gsub("\n", ' '),
        '',
        spec_type.to_s,
        content_type.to_s
      ]
      File.write(meta_path, lines.join("\n"))
    end

    def meta
      @meta ||= File.read(meta_path).lines.map(&:strip)
    end

    def description
      meta[0]
    rescue Errno::ENOENT
      name
    end

    def spec_type
      ActiveSupport::StringInquirer.new(meta[2])
    rescue Errno::ENOENT
      :response
    end

    def content_type
      @content_type ||= begin
        ct = 'html'
        ct = meta[3] if meta && meta[3].present?
        ActiveSupport::StringInquirer.new(ct)
      end
    end

    def binary?
      content_type.pdf?
    end

    def last_run_path
      path.join('last_run.txt')
    end

    def write_last_run(run_time)
      FileUtils.mkdir_p(path)
      File.write(last_run_path, run_time.to_s)
    end

    def last_run
      Time.zone.parse(File.read(last_run_path).strip)
    rescue Errno::ENOENT
      Time.zone.at(0)
    end

    private

    def splitted_description
      @splitted_description ||= begin
        if spec_type.feature?
          split = ['', 'FEAT', description]
        elsif spec_type.mailer?
          split = description.to_s.match(/(\A[a-zA-Z0-9:]+)(Mailer)(.*)/)
          split = split[1..3]
          split[0] += 'Mailer'
          split[1] = 'MAIL'
        else
          split = description.to_s.split(/\s(DELETE|GET|PATCH|POST|PUT)\s/)
        end
        split = ['', '', split[0]] if split.size == 1
        split
      end
    end

    def file_extension
      content_type.pdf? ? 'pdf' : 'html'
    end
  end
end
