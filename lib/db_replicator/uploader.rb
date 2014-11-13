require 'net/ssh'
require 'net/scp'
require 'ruby-progressbar'
module DbReplicator
  class Uploader
    def self.upload
      DbReplicator.document_action "Uploading dump file to #{DbReplicator.configuration.staging_host}", 'Upload complete' do
        pb = ProgressBar.create(format: '%t %B %p%% %a')
        Net::SCP.upload!(DbReplicator.configuration.staging_host, DbReplicator.configuration.user, File.join(DbReplicator.dumps_dir, DbReplicator.dump_file_name), DbReplicator.dump_file_name) do |_ch, _name, sent, total|
          pb.total = total
          pb.progress = sent
        end
      end

      Net::SSH.start(DbReplicator.configuration.staging_host, DbReplicator.configuration.user) do |session|
        DbReplicator.document_action 'Drop and create database', 'Database re-created' do
          session.exec! 'bundle exec rake db:drop db:create'
        end

        DbReplicator.document_action 'Importing database', 'Imported' do
          db_config = DbReplicator.db_configs('staging')
          puts "mysql -h #{db_config['host'] || 'localhost'} -P #{db_config['port'] || 3000 } -u #{db_config['username']} --password=#{db_config['password']} --database=#{db_config['database']} < #{DbReplicator.dump_file_name}"
          session.exec! "mysql -h #{db_config['host'] || 'localhost'} -P #{db_config['port'] || 3000 } -u #{db_config['username']} --password=#{db_config['password']} --database=#{db_config['database']} < #{DbReplicator.dump_file_name}"
        end

        DbReplicator.document_action 'Migrating the database', 'Migrated' do
          session.exec! 'bundle exec rake db:migrate'
        end

        DbReplicator.document_action 'Deleting remote dump file', 'Deleted' do
          session.exec! "rm -f #{DbReplicator.dump_file_name}"
        end
      end
    end
  end
end