require 'etc'
require 'spec_helper'

module DbReplicator
  describe Configuration do
    describe "#proxy_host" do
      it 'default values' do
        Configuration.new.proxy_host.should eq 'example.com'
        Configuration.new.user.should eq Etc.getlogin
      end
    end
  end
end
