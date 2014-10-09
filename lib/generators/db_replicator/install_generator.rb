module DbReplicator
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../../templates', __FILE__)
    desc 'Creates the base config file for DbReplicator, the .db_replicator_dumps directory, and adds .db_replicator_dumps to your .gitignore file.'

    def copy_initializer
      puts destination_root
      template 'db_replicator.rb', 'config/initializers/db_replicator.rb'
    end

    def create_dumps_dir
      empty_directory '.db_replicator_dumps'
    end

    def add_dumps_dir_to_gitignore
      if File.exist?(File.join(destination_root, '.gitignore'))
        append_to_file '.gitignore' do
          '.db_replicator_dumps'
        end
      else
        create_file '.gitignore', '.db_replicator_dumps'
      end
    end
  end
end
