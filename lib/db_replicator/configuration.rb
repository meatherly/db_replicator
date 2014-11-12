require 'etc'

module DbReplicator
  class Configuration
    attr_accessor :proxy_host, :user, :staging_host

    def initialize
      @proxy_host = 'example.com'
      @user = Etc.getlogin
      @staging_host = 'staging.example.com'
    end
  end
end
