class SpecViews::Directory
  attr_reader :path

  def self.for_dir_name(dir_name, content_type: :html)
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
    splitted_name.first.gsub(/Controller(_.*)$/, 'Controller').gsub(/Controller$/, '').gsub('_', '::')
  end

  def method
    splitted_name.second[0, 3]
  end

  def description
    splitted_name.third.gsub(/__pdf$/, '').humanize
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
    path.join("last_run.txt")
  end

  def write_last_run(time)
    FileUtils.mkdir_p(path)
    File.open(last_run_path, 'w') { |f| f.write(time) }
  end

  private

  def splitted_name
    @splitted_name ||= begin
      split = name.to_s.split(/_(DELETE|GET|PATCH|POST|PUT)_/)
      split = ['', '', split[0]] if split.size == 1
      split
    end
  end

  def pdf?
    name.to_s.ends_with?('__pdf')
  end

  def binary?
    pdf?
  end

  def file_extension
    pdf? ? 'pdf' : 'html'
  end
end