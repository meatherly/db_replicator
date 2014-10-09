require 'net/ssh'
require 'net/scp'
require 'ruby-progressbar'
module DbReplicator
  class Downloader
    def self.download_production
      pp DbReplicator.prod_db_configs['database']
      Net::SSH.start(DbReplicator.configuration.proxy_host, DbReplicator.configuration.user) do |session|
        DbReplicator.document_action "Creating MySQL dump file.", "Create complete." do
          session.exec! "mysqldump -u #{DbReplicator.prod_db_configs['user']} --password=#{DbReplicator.prod_db_configs['password']} #{DbReplicator.prod_db_configs['database']} > #{DbReplicator.dump_file_name}"
        end
        DbReplicator.document_action "Downloading MySQL dump file", "Download complete." do
          pb = ProgressBar.create(:format => '%t %B %p%% %a')
          session.scp.download!(DbReplicator.dump_file_name, DbReplicator.dumps_dir) do |ch, name, sent, total|
            pb.total = total
            pb.progress = sent
          end
        end
        DbReplicator.document_action "Deleting MySQL dump file on #{DbReplicator.configuration.proxy_host}", "Delete complete." do
          session.exec! "rm -f #{DbReplicator.dump_file_name}"
        end
      end
    end
  end
end
