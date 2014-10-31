# DbReplicator [![Build Status](https://travis-ci.org/meatherly/db_replicator.svg?branch=master)](https://travis-ci.org/meatherly/db_replicator)

This gem allow you to down load and import your production db to test with. 

As of now I only suport MySQL. I plan to add more adapters in the future. See TODO below.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'db_replicator', '~> 0.0.6'
```

And then execute:

    $ rails g db_replicator:install

Be sure to set the proxy_host to a server that can access your production database `db_replicator.rb` initializers file.

## Usage

You can download your production db by running:

    $ rake dbr:prod_to_local


## TODO

* Allow secure upload of production db to another enviroment. e.g. staging
* Add more adapters. 
* Write better tests!!!!


## Contributing

1. Fork it ( https://github.com/[my-github-username]/db_replicator/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
