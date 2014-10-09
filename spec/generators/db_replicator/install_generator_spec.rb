require 'spec_helper'
require 'generator_spec/test_case'
require 'generator_spec'
require 'generators/db_replicator/install_generator'

describe DbReplicator::InstallGenerator, type: :generator do
  include GeneratorSpec::TestCase
  destination File.expand_path('../../tmp', __FILE__)

  before do
    prepare_destination
    run_generator
  end

  it 'should have created the initializer with the correct contents' do
    assert_file 'config/initializers/db_replicator.rb'
  end

  it 'should create the SQL dumps directory' do
    destination_root.should have_structure {
      directory '.db_replicator_dumps'
    }
  end

  it 'should add .db_replicator_dumps to the .gitignore file' do
    destination_root.should have_structure {
      file '.gitignore' do
        '.db_replicator_dumps'
      end
    }
  end

end
