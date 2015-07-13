module EnvironmentBannerHelper
  def current_rev_info
    if git_available?
      "#{current_branch}@#{current_sha}"
    else
      read_version_file
    end
  end

  def current_branch
    if git_available?
      `git rev-parse --abbrev-ref HEAD`.chomp
    else
      ENV.fetch("CURRENT_BRANCH", "--branch-not-found--")
    end
  end

  def current_sha
    if git_available?
      `git log -1 --abbrev-commit --oneline | cut -d ' ' -f 1`
    else
      ENV.fetch("CURRENT_SHA", "--sha-not-found--")
    end
  end

  def git_available?
    to_dev_null = "> /dev/null 2>&1"
    system("which git #{to_dev_null} && git rev-parse --git-dir #{to_dev_null}")
  end

  def read_version_file
    @read_version_file ||= File.read(Rails.root.join("public", "version")).chomp
  end
end
