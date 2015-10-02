namespace :intercity do
  namespace :backup do
    desc "Intercity | Create a backup of the Intercity system"
    task create: :environment do
      configure_cron_mode
      Rake::Task["intercity:backup:db:create"].invoke

      backup = SystemBackup::Manager.new
      backup.pack
      backup.cleanup
      backup.remove_old
    end

    desc "Intercity | Restore a previously created backup"
    task restore: :environment do
      configure_cron_mode

      backup = SystemBackup::Manager.new
      backup.unpack

      Rake::Task["intercity:backup:db:restore"].invoke
      backup.cleanup
    end

    namespace :db do
      task create: :environment do
        $progress.puts "Dumping database ...".blue
        SystemBackup::Database.new.dump
        $progress.puts "done".green
      end

      task restore: :environment do
        $progress.puts "Restoring database ... ".blue
        SystemBackup::Database.new.restore
        $progress.puts "done".green
      end
    end

    def configure_cron_mode
      if ENV['CRON']
        # We need an object we can say 'puts' and 'print' to; let's use a
        # StringIO.
        require 'stringio'
        $progress = StringIO.new
      else
        $progress = $stdout
      end
    end
  end
end
