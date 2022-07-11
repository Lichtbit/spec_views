# frozen_string_literal: true

module SpecViews
  class Directory
    attr_reader :path

    def self.for_description(description, content_type: :html)
      dir_name = description.strip.gsub(/[^0-9A-Za-z.\-]/, '_').gsub('__', '_')
      dir_name = "#{dir_name}__pdf" if content_type == :pdf
      new(Rails.root.join(Rails.configuration.spec_views.directory, dir_name))
    end

    def initialize(path)
      @path = path
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

    def challenger?
      File.file?(path.join('challenger.html')) || File.file?(path.join('challenger.pdf'))
    end

    def controller_name
      splitted_description.first.gsub(/Controller(_.*)$/, 'Controller').gsub(/Controller$/, '').gsub('_', '::')
    end

    def method
      splitted_description.second[0, 3]
    end

    def description_tail
      splitted_description.third.gsub(/__pdf$/, '').humanize
    end

    def last_run
      @last_run ||= begin
        Time.zone.parse(File.read(path.join('last_run.txt')))
      rescue Errno::ENOENT
        Time.zone.at(0)
      end
    end

    def delete!
      FileUtils.remove_dir(path)
    end

    def champion_path
      path.join("view.#{file_extension}")
    end

    def champion_html
      File.read(champion_path)
    rescue Errno::ENOENT
      nil
    end

    def challenger_path
      path.join("challenger.#{file_extension}")
    end

    def write_challenger(content)
      FileUtils.mkdir_p(path)
      File.open(challenger_path, binary? ? 'wb' : 'w') { |f| f.write(content) }
    end

    def last_run_path
      path.join('last_run.txt')
    end

    def write_last_run(time)
      FileUtils.mkdir_p(path)
      File.write(last_run_path, time)
    end

    def description_path
      path.join('description.txt')
    end

    def write_description(description)
      FileUtils.mkdir_p(path)
      File.write(description_path, description)
    end

    def description
      File.read(description_path)
    rescue Errno::ENOENT
      name
    end

    def pdf?
      name.to_s.ends_with?('__pdf')
    end

    def binary?
      pdf?
    end

    private

    def splitted_description
      @splitted_description ||= begin
        split = description.to_s.split(/\s(DELETE|GET|PATCH|POST|PUT)\s/)
        split = ['', '', split[0]] if split.size == 1
        split
      end
    end

    def file_extension
      pdf? ? 'pdf' : 'html'
    end
  end
end
