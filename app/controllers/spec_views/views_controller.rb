# frozen_string_literal: true

module SpecViews
  class ViewsController < ApplicationController
    skip_authorization_check if respond_to?(:skip_authorization_check)
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
      path = directory.champion_path
      path = directory.challenger_path if params[:view] == 'challenger'
      if directory.content_type.pdf?
        send_data(
          get_view(path),
          filename: 'a.pdf',
          type: 'application/pdf', disposition: 'inline'
        )
      else
        render html: get_view(path)
      end
    end

    def compare
      @directory = directory
    end

    def diff
      if directory.content_type.pdf?
        redirect_to action: :compare
        return
      end
      @champion = get_view(directory.champion_path, html_safe: false)
      @challenger = get_view(directory.challenger_path, html_safe: false)
      @directory = directory
    end

    def preview
      @directory = directory
      @next = directories[directories.index(@directory) + 1]
      index = directories.index(@directory)
      @previous = directories[index - 1] if index.positive?
    end

    def accept
      accept_directory(directory)
      redirect_to action: :index, challenger: :next
    end

    def accept_all
      directories.each do |dir|
        accept_directory(dir) if dir.challenger?
      end
      redirect_to action: :index
    end

    def reject
      FileUtils.remove_file(directory.challenger_path)
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

    def directories
      @directories ||= Pathname.new(directory_path).children.select(&:directory?).map do |path|
        next unless File.file?("#{path}/meta.txt")
        SpecViews::Directory.new(path)
      end.compact
      latest_run = @directories.map(&:last_run).max

      @directories.sort_by! do |dir|
        prefix = '3-'
        prefix = '2-' if dir.last_run < latest_run
        prefix = '1-' if dir.challenger?
        "#{prefix}#{dir.basename}"
      end
    end

    def directory_path
      Rails.root.join(Rails.configuration.spec_views.directory)
    end

    def directory
      directories.detect { |dir| dir.to_param == params[:id] }
    end

    def get_view(path, html_safe: true)
      content = File.read(path)
      content = content.html_safe if html_safe
      content
    rescue Errno::ENOENT
      ''
    end

    def accept_directory(dir)
      FileUtils.copy_file(dir.challenger_path, dir.champion_path)
      FileUtils.remove_file(dir.challenger_path)
    end
  end
end
