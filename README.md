# HrrRbSftp::Statvfs

[![Build Status](https://travis-ci.com/hirura/hrr_rb_sftp-statvfs.svg?branch=master)](https://travis-ci.com/hirura/hrr_rb_sftp-statvfs)
[![Gem Version](https://badge.fury.io/rb/hrr_rb_sftp-statvfs.svg)](https://badge.fury.io/rb/hrr_rb_sftp-statvfs)

hrr_rb_sftp-statvfs is an hrr_rb_sftp extension that supports statvfs@openssh.com and fstatvfs@openssh.com extensions.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [Supported extensions](#supported-extensions)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)
- [Code of Conduct](#code-of-conduct)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hrr_rb_sftp'
gem 'hrr_rb_sftp-statvfs'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install hrr_rb_sftp
    $ gem install hrr_rb_sftp-statvfs

## Usage

hrr_rb_sftp-statvfs can be used with hrr_rb_sftp library.

```ruby
require "hrr_rb_sftp"
require "hrr_rb_sftp/statvfs"
```

## Supported extensions

The following extensions are additionally supported.

- statvfs@openssh.com version 2
- fstatvfs@openssh.com version 2

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hirura/hrr_rb_sftp-statvfs. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/hirura/hrr_rb_sftp-statvfs/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the HrrRbSftp::Statvfs project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/hirura/hrr_rb_sftp-statvfs/blob/master/CODE_OF_CONDUCT.md).
