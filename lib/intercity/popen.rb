require "fileutils"
require "open3"

module Intercity
  module Popen
    extend self # rubocop:disable Style/ModuleFunction

    def popen(cmd, path = nil)
      unless cmd.is_a?(Array)
        raise "System commands must be given as an array of strings"
      end

      path ||= Dir.pwd
      vars = { "PWD" => path }
      options = { chdir: path }

      FileUtils.mkdir_p(path) unless File.directory?(path)

      @cmd_output = ""
      @cmd_status = 0
      Open3.popen3(vars, *cmd, options) do |stdin, stdout, stderr, wait_thr|
        # We are not using stdin so we should close it, in case the command we
        # are running waits for input.
        stdin.close
        @cmd_output << stdout.read
        @cmd_output << stderr.read
        @cmd_status = wait_thr.value.exitstatus
      end

      [@cmd_output, @cmd_status]
    end
  end
end
