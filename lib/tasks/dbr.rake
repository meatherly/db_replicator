db_replicator_lib = File.expand_path(File.dirname(File.dirname(__FILE__)))
require "#{db_replicator_lib}/db_replicator"

namespace :dbr do
  desc "Imports the production db into the current machines environment db"
  task prod_to_local: [:environment, :download_prod_db] do
    importer = DbReplicator::Importer.new('development')
    importer.import_db!
    puts "******* You now have production data in your current database *******"
  end

  desc "Download the production db dump to ~/mysql_dumps"
  task download_prod_db: :environment do
    DbReplicator::Downloader.download_production
  end
end





