$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'db_replicator/version'
require 'db_replicator/tasks'
require 'db_replicator/configuration'
require 'db_replicator/downloader'
require 'db_replicator/importer'
require 'colorize'

module DbReplicator
  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.document_action(before, after, &block)
    puts before.colorize(:yellow)
    yield block
    puts after.colorize(:green)
  end

  def self.db_configs(db_env=Rails.env)
    ActiveRecord::Base.configurations[db_env]
  end

  def self.dump_file_name
    ActiveRecord::Base.configurations['production']['database'] + '.sql'
  end

  def self.dumps_dir
    File.join Rails.root, '.db_replicator_dumps'
  end

  def self.dump_file
    File.join(dumps_dir, dump_file_name)
  end

  def self.prod_db_configs
    @prod_configs ||= DbReplicator.db_configs('production')
  end
end
