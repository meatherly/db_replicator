module DbReplicator
  class Importer
    attr_accessor :to_db_env, :db_env
    def initialize(to_db_env)
      @to_db_env = to_db_env
      @to_db_configs = DbReplicator.db_configs(@to_db_env)
      if @to_db_configs['adapter'] == 'sqlite3'
        @tmp_db_configs = create_tmp_db_configs
      else
        @tmp_db_configs = nil
      end
    end

    def import_db!
      DbReplicator.document_action "Executing db:drop && db:create to get a fresh database", "Fresh database created." do
        create_fresh_db
      end
      DbReplicator.document_action "Importing mysql dump to #{@to_db_configs['database']} database", "Import complete." do
        pp @tmp_db_configs
        if @tmp_db_configs
          DbReplicator.document_action "Transfering db to sqlite3", "Transfer complete" do
            convert_sql_dump_and_import
          end
        else
          puts "Executing: mysql -u root #{@to_db_configs['database']} < #{DbReplicator.dump_file}"
          exec "mysql -u root #{@to_db_configs['database']} < #{DbReplicator.dump_file}"
        end
      end
      DbReplicator.document_action "Executing db:migrate to update database Just in case their are pending migrations", "Migrate complete." do
        system "bundle exec rake db:migrate"
      end
    end
    
    private

    def convert_sql_dump_and_import
        DbReplicator.document_action "Creating temp db for transfer #{create_tmp_db_configs['database']}", "Create complete" do
          ActiveRecord::Tasks::DatabaseTasks.create(create_tmp_db_configs)
        end        
        DbReplicator.document_action "Importing data to temp db. DB: #{create_tmp_db_configs['database']}; File: #{DbReplicator.dump_file}", "Import complete" do
          puts "Executing: mysql -u root #{create_tmp_db_configs['database']} < #{DbReplicator.dump_file}"
          system "mysql -u root #{create_tmp_db_configs['database']} < #{DbReplicator.dump_file}"
        end
        DbReplicator.document_action "Starting data transfer", "Data transfer complete." do
          puts "Executing: sequel #{DbReplicator.prod_db_configs['adapter']}://localhost/#{create_tmp_db_configs['database']}?user=root -C sqlite://#{@to_db_configs['database']}"
          system "sequel #{DbReplicator.prod_db_configs['adapter']}://localhost/#{create_tmp_db_configs['database']}?user=root -C sqlite://#{@to_db_configs['database']}" 
        end      
    end

    def create_tmp_db_configs
      tmp_configs = @to_db_configs.clone
      tmp_configs['database'] = "#{DbReplicator.prod_db_configs['database']}_db_replicator"
      # tmp_configs['host'] = 'localhost'
      tmp_configs.reject!{|k, v| ['password', 'username'].include?(k.to_s) || v.nil? }
      tmp_configs
    end

    def create_fresh_db
      system "bundle exec rake db:drop db:create"
    end
  end
end
