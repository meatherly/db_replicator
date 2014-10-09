require 'spec_helper'
describe DbReplicator do

  describe "#configure" do
    before do
      DbReplicator.configure do |config|
        config.proxy_host = 'www.example.com'
        config.user = 'user'
      end
    end

    it 'returns the custom values' do
      DbReplicator.configuration.proxy_host.should == 'www.example.com'
      DbReplicator.configuration.user.should == 'user'
    end
  end
end
