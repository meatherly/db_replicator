require 'db_replicator/exec_command'
module DbReplicator
  class Importer
    include ExecCommand
    attr_accessor :to_db_env, :tmp_db_configs
    def initialize(to_db_env)
      @to_db_env = to_db_env
      @to_db_configs = DbReplicator.db_configs(@to_db_env)
      if @to_db_configs['adapter'] == 'sqlite3'
        set_tmp_db_configs
      else
        @tmp_db_configs = nil
      end
    end

    def import_db!
      DbReplicator.document_action 'Executing db:drop && db:create to get a fresh database', 'Fresh database created.' do
        create_fresh_db
      end
      DbReplicator.document_action "Importing mysql dump to #{@to_db_configs['database']} database", 'Import complete.' do
        if @tmp_db_configs
          DbReplicator.document_action 'Transfering db to sqlite3', 'Transfer complete' do
            convert_sql_dump_and_import
          end
        else
          puts "mysql -h #{@to_db_configs['host'] || 'localhost'} -P #{@to_db_configs['port'] || 3000 } -u #{@to_db_configs['username']} --password=#{@to_db_configs['password']} --database=#{@to_db_configs['database']} < #{DbReplicator.dump_file}"
          exec_cmd "mysql -h #{@to_db_configs['host'] || 'localhost'} -P #{@to_db_configs['port'] || 3000 } -u #{@to_db_configs['username']} --password=#{@to_db_configs['password']} --database=#{@to_db_configs['database']} < #{DbReplicator.dump_file}"
        end
      end
      DbReplicator.document_action 'Executing db:migrate to update database Just in case their are pending migrations', 'Migrate complete.' do
        exec_cmd 'bundle exec rake db:migrate'
      end
    end

    private

    def convert_sql_dump_and_import
      DbReplicator.document_action "Creating temp db for transfer #{@tmp_db_configs['database']}", 'Create complete' do
        ActiveRecord::Tasks::DatabaseTasks.create(@tmp_db_configs)
      end
      DbReplicator.document_action "Importing data to temp db. DB: #{@tmp_db_configs['database']}; File: #{DbReplicator.dump_file}", 'Import complete' do
        puts "Executing: mysql -u root --database=#{@tmp_db_configs['database']} < #{DbReplicator.dump_file}"
        exec_cmd "mysql -u root --database=#{@tmp_db_configs['database']} < #{DbReplicator.dump_file}"
      end
      DbReplicator.document_action 'Starting data transfer', 'Data transfer complete.' do
        puts "Executing: sequel #{DbReplicator.prod_db_configs['adapter']}://localhost/#{@tmp_db_configs['database']}?user=root -C sqlite://#{@to_db_configs['database']}"
        exec_cmd "sequel #{DbReplicator.prod_db_configs['adapter']}://localhost/#{@tmp_db_configs['database']}?user=root -C sqlite://#{@to_db_configs['database']}"
      end
    end

    def set_tmp_db_configs
      tmp_configs = @to_db_configs.clone
      tmp_configs['database'] = "#{DbReplicator.prod_db_configs['database']}_db_replicator"
      @tmp_db_configs = tmp_configs.reject { |k, v| %w(password username).include?(k.to_s) || v.nil? }
    end

    def create_fresh_db
      exec_cmd 'bundle exec rake db:drop db:create'
    end
  end
end
