require "yaml"

module SystemBackup
  class Database
    attr_reader :config, :db_dir

    def initialize
      @config = YAML.load_file(File.join(Rails.root, "config", "database.yml"))[Rails.env]
      @db_dir = File.join(Settings.backup.path, "db")
    end

    def dump
      FileUtils.rm_rf(@db_dir)
      # Ensure the parent dir of @db_dir exists
      FileUtils.mkdir_p(Settings.backup.path)
      # Fail if somebody raced to create @db_dir before us
      FileUtils.mkdir(@db_dir, mode: 0700)

      $progress.print "Dumping PostgreSQL database #{config['database']} ... "
      pg_env
      # Pass '--clean' to include 'DROP TABLE' statements in the DB dump.
      success = system("pg_dump", "--clean", config["database"], out: db_file_name)

      report_success(success)
      abort "Backup failed" unless success

      $progress.print "Compressing database ... "
      success = system("gzip", db_file_name)
      report_success(success)
      abort "Backup failed: compress error" unless success
    end

    def restore
      $progress.print "Decompressing database ... "
      success = system("gzip", "-d", db_file_name_gz)
      report_success(success)
      abort "Restore failed: decompress error" unless success

      $progress.print "Restoring PostgreSQL database #{config['database']} ... "
      pg_env
      system("psql", config["database"], "-f", db_file_name)
      report_success(success)
      abort "Restore failed" unless success
    end

    protected

    def db_file_name
      File.join(db_dir, "database.sql")
    end

    def db_file_name_gz
      File.join(db_dir, "database.sql.gz")
    end

    def pg_env
      ENV["PGUSER"] = config["username"] if config["username"]
      ENV["PGHOST"] = config["host"] if config["host"]
      ENV["PGPORT"] = config["port"].to_s if config["port"]
      ENV["PGPASSWORD"] = config["password"].to_s if config["password"]
    end

    def report_success(success)
      if success
        $progress.puts "[DONE]".green
      else
        $progress.puts "[FAILED]".red
      end
    end
  end
end
