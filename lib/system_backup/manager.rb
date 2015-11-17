module SystemBackup
  class Manager
    def pack
      # saving additional informations
      s = {}
      s[:db_version] = "#{ActiveRecord::Migrator.current_version}"
      s[:backup_created_at] = Time.now
      s[:intercity_version] = Intercity::VERSION
      s[:tar_version] = tar_version
      s[:skipped] = ENV["SKIP"]
      tar_file = "#{s[:backup_created_at].to_i}_intercity_backup.tar"

      Dir.chdir(Settings.backup.path) do
        File.open("#{Settings.backup.path}/backup_information.yml",
                  "w+") do |file|
          file << s.to_yaml.gsub(/^---\n/, "")
        end

        # create archive
        $progress.print "Creating backup archive: #{tar_file} ... "
        # Set file permissions on open to prevent chmod races.
        tar_system_options = { out: [tar_file, "w", Settings.backup.archive_permissions] }
        if Kernel.system("tar", "-cf", "-", *backup_contents, tar_system_options)
          $progress.puts "done".green
        else
          $progress.print "creating archive #{tar_file} failed".red
          abort "Backup failed"
        end
      end
    end

    def cleanup
      $progress.print "Deleting tmp directories ... "

      backup_contents.each do |dir|
        next unless File.exist?(File.join(Settings.backup.path, dir))

        if FileUtils.rm_rf(File.join(Settings.backup.path, dir))
          $progress.puts "done".green
        else
          $progress.print "deleting tmp directory '#{dir}' failed".red
          abort "Backup failed"
        end
      end
    end

    def remove_old
      # delete backups
      $progress.print "Deleting old backups ... "
      keep_time = Settings.backup.keep_time.to_i

      if keep_time > 0
        removed = 0

        Dir.chdir(Settings.backup.path) do
          file_list = Dir.glob("*_settings_backup.tar")
          file_list.map! { |f| $1.to_i if f =~ /(\d+)_settings_backup.tar/ }
          file_list.sort.each do |timestamp|
            if Time.at(timestamp) < (Time.now - keep_time)
              if Kernel.system(*%W(rm #{timestamp}_settings_backup.tar))
                removed += 1
              end
            end
          end
        end

        $progress.puts "done. (#{removed} removed)".green
      else
        $progress.puts "skipping".yellow
      end
    end

    def unpack # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity
      Dir.chdir(Settings.backup.path)

      # check for existing backups in the backup dir
      file_list = Dir.glob("*_intercity_backup.tar").each.map { |f| f.split(/_/).first.to_i }
      $progress.print "no backups found" if file_list.count == 0

      if file_list.count > 1 && ENV["BACKUP"].nil?
        $progress.print "Found more than one backup, please specify which one you want to restore:"
        $progress.print "rake intercity:backup:restore BACKUP=timestamp_of_backup"
        exit 1
      end

      tar_file = if ENV["BACKUP"].nil?
                   File.join("#{file_list.first}_intercity_backup.tar")
                 else
                   File.join(ENV["BACKUP"] + "_intercity_backup.tar")
                 end

      unless File.exist?(tar_file)
        $progress.print "The specified backup doesn't exist!"
        exit 1
      end

      $progress.print "Unpacking backup ... "

      if Kernel.system(*%W(tar -xf #{tar_file}))
        $progress.puts "done".green
      else
        $progress.puts "unpacking backup failed".red
        exit 1
      end

      ENV["VERSION"] = "#{settings[:db_version]}" if settings[:db_version].to_i > 0

      # restoring mismatching backups can lead to unexpected problems
      if settings[:intercity_version] != Intercity::VERSION # rubocop:disable Style/GuardClause
        $progress.puts "Intercity version mismatch:".red
        $progress.puts "  Your current Intercity version (#{Intercity::VERSION}) differs " \
          "from the Intercity version in the backup!".red
        $progress.puts "  Please switch to the following version and try again:".red
        $progress.puts "  version: #{settings[:intercity_version]}".red
        $progress.puts " "
        $progress.puts "Hint: git checkout v#{settings[:intercity_version]}"
        exit 1
      end
    end

    def tar_version
      tar_version, _ = Intercity::Popen.popen(%w(tar --version)) # rubocop:disable Style/TrailingUnderscoreVariable, Metrics/LineLength
      tar_version.force_encoding("locale").split("\n").first
    end

    def skipped?(item)
      settings[:skipped] && settings[:skipped].include?(item)
    end

    private

    def backup_contents
      folders_to_backup + ["backup_information.yml"]
    end

    def folders_to_backup
      folders = %w( db )

      if ENV["SKIP"]
        return folders.reject { |folder| ENV["SKIP"].include?(folder) }
      end

      folders
    end

    def settings
      @settings ||= YAML.load_file("backup_information.yml")
    end
  end
end
