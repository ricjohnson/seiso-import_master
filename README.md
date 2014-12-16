# Seiso::ImportMaster

[![Gem Version](https://badge.fury.io/rb/seiso-import_master.svg)](http://badge.fury.io/rb/seiso-import_master)
[![Build Status](https://travis-ci.org/ExpediaDotCom/seiso-import_master.svg)](https://travis-ci.org/ExpediaDotCom/seiso-import_master)
[![Inline docs](http://inch-ci.org/github/ExpediaDotCom/seiso-import_master.svg?branch=master)](http://inch-ci.org/github/ExpediaDotCom/seiso-import_master)

Imports Seiso data master files into Seiso.

See [Manage Your Service Data with GitHub, Jenkins & Seiso](http://seiso.io/guides/manage-your-service-data-with-github-jenkins-seiso/) for more details on the overall approach.

See [Seiso Data Master Schemas](http://seiso.io/docs/current/user-manual/sdm-schemas/) for the data master schemas.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'seiso-import_master'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install seiso-import_master

## Usage

1. Create a directory `~/.seiso-importers`
2. Place appropriately modified copy of `seiso.yml.sample` in there.
3. Run `seiso-import-master file [, file2, ...]` to perform the import. Note that you can use `-f yaml` for YAML files (the default is `-f json`).

## Contributing

1. Fork it ( https://github.com/ExpediaDotCom/seiso-import_master/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new pull request.
