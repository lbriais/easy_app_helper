# EasyAppHelper


This [gem] [1] provides a suite of helpers for command line applications.
The goal is to be as transparent as possible for the application whilst providing consistent helpers that add dedidacted behaviours to your application.

Currently the only runtime dependency is on the [Slop gem] [2].



## Installation

Add this line to your application's Gemfile:

    gem 'easy_app_helper'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install easy_app_helper

## Usage

To benefit from the different helpers. Once you installed the gem, the only thing you need to do is:

```ruby
require 'easy_app_helper'
````

and then in the "main class" of your application, include the modules you want to use and call init_app_helper in the initialize method. Then what you can do with each 
module is defined by each module.

The basic behaviour (when you include EasyAppHelper), actually adds basic command line handling (actually handled by slop), and provides the mechanism to enable you to add any other EasyAppHelper module.

ex:
```ruby
require 'easy_app_helper'
class MyApp
 	include EasyAppHelper
	def initialize
		init_app_helper "my_app"
	end
end
```

This basically does... nothing. I mean the only behaviour it adds to your application is the ability to pass --help to the application to see the inline help (that it builds). On top of this you then have access to some other command line options like --auto, --simulate, --verbose, but for those it is up to your application to check their value using the app_config attribute which is now

You could then do something like:
```ruby
require 'easy_app_helper'
class MyApp
 	include EasyAppHelper
	def initialize
		"my_app" init_app_helper "my_app", "My Super Application", "This is the application everybody was waiting for.", "v 1.0"
		if app_config[:verbose]
			 puts "Waouh, hello World !!"
		end
	end
end
```
You can actually access any field from your application configuration through the app_config attribute.

### Other modules
Some other modules are provided:

* EasyAppHelper::Logger	provides logging facilities and config line options including log-level, log-file etc...
* EasyAppHelper::Config provides easy YAML based configuration to your script with multiple level of override (admin wide -> system wide -> user -> command line options -> --config-file). All the configuration being accessible through the app_config hash attribute

See classes documentation for more information.

### Debugging

If you want to debug what happens during the framework instanciation, you can use the DEBUG_EASY_MODULES environment variable.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


[1]: https://rubygems.org/gems/easy_app_helper        "EasyAppHelper gem"
[2]: https://rubygems.org/gems/slop        "Slop gem"