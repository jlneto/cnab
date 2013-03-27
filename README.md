# Cnab

[![Gem Version](https://badge.fury.io/rb/cnab.png)](http://badge.fury.io/rb/cnab) [![Build Status](https://travis-ci.org/zertico/cnab.png)](https://travis-ci.org/zertico/cnab) [![Coverage Status](https://coveralls.io/repos/zertico/cnab/badge.png?branch=master)](https://coveralls.io/r/zertico/cnab) [![Code Climate](https://codeclimate.com/github/zertico/cnab.png)](https://codeclimate.com/github/zertico/cnab)

Gem used to parse return from Brazil banks in format of cnab files. It is based on the version 08.7 of the cnab.
Right now it has support only for Segmento T and Segmento U.

## Installation

Add this line to your application's Gemfile:

    gem 'cnab'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cnab

## Usage

```ruby
cnab = Cnab.parse('path/to/your/file')
```

This method will return the file parsed in objects.

If you need to merge the segments T and U, just pass true as the optional parameter:

```ruby
cnab = Cnab.parse('path/to/your/file', true)
```

## TODO

* Add support for another type of segments

## Mantainers
[@plribeiro3000](https://github.com/plribeiro3000)

[@mfbmina](https://github.com/mfbmina)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
