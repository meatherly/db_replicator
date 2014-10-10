require 'open3'
module ExecCommand
  def exec_cmd(cmd)
    Open3.popen2e(cmd) do |_, stdout_err, wait_thr|
      while line = stdout_err.gets
        puts line
      end

      exit_status = wait_thr.value
      unless exit_status.success?
        raise "Shell Error From: #{cmd}".colorize(:red)
      end
    end
  end
end
