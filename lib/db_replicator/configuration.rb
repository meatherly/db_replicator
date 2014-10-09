require 'etc'

module DbReplicator
  class Configuration
    attr_accessor :proxy_host, :user

    def initialize
      @proxy_host = 'example.com'
      @user = Etc.getlogin
    end
  end
end
