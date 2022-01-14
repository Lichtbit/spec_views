# frozen_string_literal: true

module SpecViews
  class ViewsController < ApplicationController
    skip_authorization_check
    layout 'spec_views'

    def index
      @directories = directories
      @latest_run = directories.map(&:last_run).max
      return unless params[:challenger] == 'next'

      first = @directories.detect(&:challenger?)
      if first
        redirect_to(action: :compare, id: first)
      else
        redirect_to(action: :index, challenger: nil)
      end
    end

    def show
      view = filename('view')
      view = filename('challenger') if params[:view] == 'challenger'
      if pdf?
        send_data(
          get_view(view),
          filename: 'a.pdf',
          type: 'application/pdf', disposition: 'inline'
        )
      else
        render html: get_view(view)
      end
    end

    def compare
      @directory = directory
    end

    def preview
      @directory = directory
      @next = directories[directories.index(@directory) + 1]
      index = directories.index(@directory)
      @previous = directories[index - 1] if index > 0
    end

    def accept
      accept_directory(params[:id])
      redirect_to action: :index, challenger: :next
    end

    def accept_all
      directories.each do |dir|
        accept_directory(dir) if dir.challenger?
      end
      redirect_to action: :index
    end

    def reject
      challenger = file_path(filename('challenger'))
      FileUtils.remove_file(challenger)
      redirect_to action: :index, challenger: :next
    end

    def destroy_outdated
      @directories = directories
      @latest_run = directories.map(&:last_run).max
      @directories.each do |dir|
        dir.delete! if dir.last_run < @latest_run
      end
      redirect_to action: :index
    end

    private

    class Directory
      attr_reader :path

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
        splitted_name.first.gsub(/Controller(_.*)$/, 'Controller').gsub('_', '::')
      end

      def method
        splitted_name.second
      end

      def description
        splitted_name.third.humanize
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

      private

      def splitted_name
        @splitted_name ||= name.to_s.split(/_(DELETE|GET|PATCH|POST|PUT)_/)
      end
    end

    def directories
      @directories ||= Pathname.new(directory_path).children.select(&:directory?).map do |path|
        Directory.new(path)
      end.sort_by(&:basename)
    end

    def directory_path
      Rails.root.join(Rails.configuration.spec_views.directory)
    end

    def directory
      directories.detect { |dir| dir.to_param == params[:id] }
    end

    def get_view(filename = nil)
      filename ||= pdf? ? 'view.pdf' : 'view.html'
      File.read(file_path(filename)).html_safe # rubocop:disable Rails/OutputSafety
    rescue Errno::ENOENT
      ''
    end

    def file_path(filename, id: nil)
      id ||= params[:id]
      id = id.to_param if id.respond_to?(:to_param)
      directory_path.join(id, filename)
    end

    def filename(base = 'view')
      pdf? ? "#{base}.pdf" : "#{base}.html"
    end

    def pdf?
      params[:id] && params[:id].end_with?('__pdf')
    end

    def accept_directory(id)
      champion = file_path(filename('view'), id: id)
      challenger = file_path(filename('challenger'), id: id)
      FileUtils.copy_file(challenger, champion)
      FileUtils.remove_file(challenger)
    end
  end
end
