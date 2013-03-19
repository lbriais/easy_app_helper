# EasyAppHelper

This gem (https://rubygems.org/gems/easy_app_helper) provides a suite of helpers for command line applications.
The goal is to be as transparent as possible for application whilst providing consistent helpers that add dedidacted behaviours to your application.

Currently the only dependency is on "slop" (https://rubygems.org/gems/slop).



## Installation

Add this line to your application's Gemfile:

    gem 'easy_app_helper'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install easy_app_helper

## Usage

To benefit from the different helpers. Once you installed the gem, the only thing you need to do is:

require 'easy_app_helper'

and then in the "main class" of your application, include the modules you want to use and call init_app_helper in the initialize method. Then what you can do with each 
module is defined by each module.

The basic behaviour (when you include EasyAppHelper), actually adds basic command line handling (actually handled by slop), and provides the mechanism to enable you
to add any other EasyAppHelper module.

ex:

require 'easy_app_helper'

class MyApp
      include EasyAppHelper

      def initialize
      	  init_app_helper "my_app"
      end
end

This basically does... nothing.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
