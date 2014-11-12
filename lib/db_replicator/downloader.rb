require 'net/ssh'
require 'net/scp'
require 'ruby-progressbar'
module DbReplicator
  class Downloader
    def self.mysqldump_command
      "mysqldump -h #{DbReplicator.prod_db_configs['host']} -P #{DbReplicator.prod_db_configs['port']} -u #{DbReplicator.prod_db_configs['username']} --password=#{DbReplicator.prod_db_configs['password']} --verbose #{DbReplicator.prod_db_configs['database']} > #{DbReplicator.dump_file_name}"
    end
    def self.download_production
      Net::SSH.start(DbReplicator.configuration.proxy_host, DbReplicator.configuration.user) do |session|
        DbReplicator.document_action 'Creating MySQL dump file.', 'Create complete.' do
          puts "Connecting to #{DbReplicator.configuration.proxy_host} and executing: #{mysqldump_command}".colorize(:yellow)
          puts "mysqldump output #{"-" * 80}"
          puts session.exec! mysqldump_command
        end
        DbReplicator.document_action 'Downloading MySQL dump file', 'Download complete.' do
          pb = ProgressBar.create(format: '%t %B %p%% %a')
          session.scp.download!(DbReplicator.dump_file_name, DbReplicator.dumps_dir) do |_ch, _name, sent, total|
            pb.total = total
            pb.progress = sent
          end
        end
        DbReplicator.document_action "Deleting MySQL dump file on #{DbReplicator.configuration.proxy_host}", 'Delete complete.' do
          session.exec! "rm -f #{DbReplicator.dump_file_name}"
        end
      end
    end
  end
end
