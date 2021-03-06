# -*- encoding: utf-8 -*-

module Webgen

  # This error class and its descendants are only used in webgen when user-visible errors need to be
  # created. For example, when the format of the configuration is not valid. Use the built-in Ruby
  # error classes for all other error situations!
  class Error < StandardError

    # The location where the error happened (this can be set to a file name, a class name, ...).
    attr_accessor :location

    # Contains the path name if the error is related to a specific source or destination path,
    attr_accessor :path

    # Create a new Error object.
    #
    # If +msg_or_error+ is a String, it is treated as the error message. If it is an exception, the
    # exception is wrapped. The +location+ parameter can be used to further describe where the error
    # happened and the +path+ parameter can be used to associate a source or destination path with
    # the error.
    def initialize(msg_or_error, location = nil, path = nil)
      if msg_or_error.kind_of?(String)
        super(msg_or_error)
      else
        super(msg_or_error.message)
        set_backtrace(msg_or_error.backtrace)
      end
      @location, @path = location, path.to_s
    end

    def message(wrapped_msg_only = false) # :nodoc:
      return super().gsub(/\n/, "\n    ") if wrapped_msg_only
      msg = 'Error'
      msg << " at #{@location}" if @location
      msg << (!@path.to_s.empty? ? " while working on <#{@path}>" : '')
      msg << ":\n    " << super().gsub(/\n/, "\n    ")
    end

    # Return the error line by inspecting the backtrace of the given +error+ instance.
    def self.error_line(error)
      (error.is_a?(::SyntaxError) ? error.message : error.backtrace[0]).scan(/:(\d+)/).first.first.to_i rescue nil
    end

    # Return the file name where the error occured.
    def self.error_file(error)
      (error.is_a?(::SyntaxError) ? error.message : error.backtrace[0]).scan(/(?:^|\s)(.*?):(\d+)/).first.first
    end

  end


  # This error is raised when an error condition occurs during the creation of a node.
  class NodeCreationError < Error

    def message # :nodoc:
      msg = 'Error'
      msg << " at #{@location}" if @location
      msg << ' while creating a node'
      msg << (!@path.to_s.empty? ? " from <#{@path}>" : '')
      msg << ":\n    " << super(true)
    end

  end


  # This error is raised when an error condition occurs during rendering of a node.
  class RenderError < Error

    # The path of the file where the error happened. This can be different from #path (e.g. a page
    # file is rendered but the error happens in a used template).
    attr_accessor :error_path

    # The line number in the +error_path+ where the errror happened.
    attr_accessor :line

    # Create a new RenderError.
    def initialize(msg_or_error, location = nil, path = nil, error_path = nil, line = nil)
      super(msg_or_error, location, path)
      @error_path = error_path || (Exception === msg_or_error ? self.class.error_file(msg_or_error) : nil)
      @line = line || (Exception === msg_or_error ? self.class.error_line(msg_or_error) : nil)
    end

    def message # :nodoc:
      msg = 'Error'
      msg << " at #{@location}" if @location
      if @error_path
        msg += " in <#{@error_path}"
        msg += ":~#{@line}" if @line
        msg += ">"
      end
      msg << ' while rendering'
      msg << (!@path.to_s.empty? ? " <#{@path}>" : ' the website')
      msg << ":\n    " << super(true)
    end

  end


  # This error is raised when a needed library is not found.
  class LoadError < Error

    # The name of the library that is missing.
    attr_reader :library

    # The name of the Rubygem that provides the missing library.
    attr_reader :gem

    # Create a new LoadError.
    #
    # If +library_or_error+ is a String, it is treated as the missing library name and an approriate
    # error message is created. If it is an exception, the exception is wrapped.
    def initialize(library_or_error, location = nil, path = nil, gem = nil)
      if library_or_error.kind_of?(String)
        msg = "The needed library '#{library_or_error}' is missing."
        msg << " You can install it with rubygems by running 'gem install #{gem}'!" if gem
        super(msg, location, path)
        @library = library_or_error
      else
        super(library_or_error, location, path)
        @library = nil
      end
      @gem = gem
    end

  end


  # This error is raised when a needed bundle is not found.
  class BundleLoadError < Error

    # The name of the bundle that is missing.
    attr_reader :bundle

    # Create a new BundleLoadError.
    def initialize(bundle)
      super("The needed bundle '#{bundle}' is missing.", nil, nil)
    end

  end



  # This error is raised when a needed external command is not found.
  class CommandNotFoundError < Error

    # The command that is missing.
    attr_reader :cmd

    # Create a new CommandNotFoundError.
    #
    # The parameter +cmd+ specifies the command that is missing.
    def initialize(cmd, location = nil, path = nil)
      super("The needed command '#{cmd}' is missing!", location, path)
      @cmd = cmd
    end

  end

end
