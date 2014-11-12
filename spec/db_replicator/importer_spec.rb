require 'spec_helper'
require "active_record/railtie"
module DbReplicator
  describe Importer do
    before do
      DbReplicator.stub(:prod_db_configs) { Hash["adapter" => "mysql2", "user" => "user1", "database" => "development", "password" => "123"] }
    end
    describe "tmp_db_configs" do
      before do
        expect(DbReplicator).to receive(:db_configs).and_return(Hash['adapter', 'sqlite3'])
      end
      it 'will set the tmp_db_configs if the development adapter is sqlite3' do
        importer = Importer.new('development')
        importer.tmp_db_configs['database'].should == 'development_db_replicator'
      end
    end
    describe "#import_db!" do
      let(:importer) { Importer.new('development') }
      context 'convert mysql to sqlite3' do
        before do
          DbReplicator.stub(:dump_file) {'dump_file'}
          expect(DbReplicator).to receive(:db_configs).with('development').and_return(Hash['adapter', 'sqlite3', 'database', 'db/development.sqlite3'])
          expect(ActiveRecord::Tasks::DatabaseTasks).to receive(:create)
          expect(importer).to receive(:exec_cmd).with("bundle exec rake db:drop db:create")
          expect(importer).to receive(:exec_cmd).with("mysql -u root --database=development_db_replicator < #{DbReplicator.dump_file}")
          expect(importer).to receive(:exec_cmd).with("sequel #{DbReplicator.prod_db_configs['adapter']}://localhost/development_db_replicator?user=root -C sqlite://db/development.sqlite3")
          expect(importer).to receive(:exec_cmd).with("bundle exec rake db:migrate")
        end
        it 'convert the mysql db to sqlite3' do
          importer.import_db!
        end
      end
      context 'env db is already mysql' do
        before do
          DbReplicator.stub(:dump_file) {'dump_file'}
          expect(DbReplicator).to receive(:db_configs).with('development').and_return(Hash['adapter', 'mysql2', 'database', 'development', 'username', 'apps', 'password', 'p@ssw0rd'])
          expect(importer).to receive(:exec_cmd).with("bundle exec rake db:drop db:create")
          expect(importer).to receive(:exec_cmd).with("mysql -h localhost -P 3000 -u apps --password=p@ssw0rd --database=development < #{DbReplicator.dump_file}")
          expect(importer).to receive(:exec_cmd).with("bundle exec rake db:migrate")
        end

        it 'will import the prod db into the mysql db' do
          importer.import_db!
        end
      end
    end
  end
end
