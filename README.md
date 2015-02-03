# EasyAppHelper v3
 [![Build Status](https://travis-ci.org/lbriais/easy_app_helper.svg)](https://travis-ci.org/lbriais/easy_app_helper)
 [![Gem Version](https://badge.fury.io/rb/easy_app_helper.svg)](http://badge.fury.io/rb/easy_app_helper)

Every Ruby script on Earth has basically the same fundamental needs:

* Config files everywhere accross the system, some of them belonging to the administrator some to the user
  running the application, some coming from the command line options and more...
* Support command line options directly overriding some of the properties defined in config files.
* Display a nice command-line options help
* Logging stuff either to STDOUT, STDERR or to a specific log file.

__If, like everyone, you have those basic needs, then this [gem][EAH] is definitely for you.__

This is a complete rewrite of the [easy_app_helper gem v1.x][EAH1] now based on the [stacked_config Gem][SC] for the
config file management part, but it maintains some compatibility with previous version. See
[compatibility issues with previous versions](#compatibility-issues-with-previous-versions) for more information.

If you are writing command line applications, I hope you will like it because it's very easy to use,
and as unobtrusive as possible (you choose when you want to include or use as a module) while providing
a ready-for-prod config, logger and command line management.


## Installation

Add this line to your application's Gemfile:

    gem 'easy_app_helper', '~> 3.0'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install easy_app_helper


## Usage

### The config files handling

Basically all the config files management is delegated to the [stacked_config Gem][SC]. Please check its documentation
to know how it works. In your own script the 'merged' ([read for more][SC]) configuration is available using the
`EasyAppHelper.config` object.

To use it, you just need to require it, you can or not include the `EasyAppHelper` module. It's methods are both
available as module or mixin methods.

```ruby
require 'easy_app_helper'

# You can directly access the config or the logger through the **EasyAppHelper** module
puts "The application verbose flag is #{EasyAppHelper.config[:verbose]}"

# Fed up with the 'EasyAppHelper' prefix ? Just include the module where you want
include EasyAppHelper
puts "The application verbose flag is #{config[:verbose]}"
```

Check the [stacked_config Gem][SC] help to further understand about the `config` object.

### The logger

The logger behaviour is tightly coupled with config part and there are few config options already available to drive
the way it will work. By default the logger will just log to the `File::NULL` device (/dev/null on Unix systems).

* __debug__: if specified the logger will log to STDOUT.
* __debug-on-err__: if specified the logger will log to STDERR.
* __log-level__: Specify the logger log level from 0 to 5, default 2 (in your code you can use one of the
  `Logger::Severity.constants` if you prefer).
* __log-file__: Specifies a file to log to.

By default the `EasyAppHelper.logger` is an instance of a standard `Logger` but can specify your own using the
`EasyAppHelper::Logger::Initializer.setup_logger` method.

```ruby
require 'easy_app_helper'

# You can directly use the logger according to the command line, or config file, flags
# This will do nothing unless --debug is set and --log-level is set to the correct level
EasyAppHelper.logger.info "Hi guys!"

# Fed up with the **EasyAppHelper** prefix ? Just include the module where you want
include EasyAppHelper

logger.level = 1
logger.info "Hi guys!... again"
```

`EasyAppHelper` introduces a nice method coupled with both the `verbose` option and log-related options:
`puts_and_logs`. It will perform a `puts` if the `verbose` option is set. And on top it will log at 'info' level if
 the `debug` option is set (or on STDERR if `debug-on-err` is set).

```ruby
require 'easy_app_helper'

include EasyAppHelper

puts_and_logs 'Hello world'
```

### The command line options

The command line options is one of the config layers maintained by the [stacked_config Gem][SC], and therefore there
is not much to say except that [easy_app_helper][EAH] adds itself some options related to the logging as seen in the
[logger part](#the-logger).

Of course as described in the [stacked_config Gem][SC] documentation, you can define your own options:

Let's say you have a `my_script.rb`:

```ruby
#!/usr/bin/env ruby

require 'easy_app_helper'

include EasyAppHelper

APP_NAME = "My super application"
VERSION = '0.0.1'
DESCRIPTION = 'This application is a proof of concept for EasyAppHelper.'

config.describes_application(app_name: APP_NAME, app_version: VERSION, app_description: DESCRIPTION)


config.add_command_line_section('My script options') do |slop|
  slop.on :u, :useless, 'Stupid option', :argument => false
  slop.on :anint, 'Stupid option with integer argument', :argument => true, :as => Integer
end

if config[:help]
    puts config.command_line_help
end
```

Then if you do:

    $ ./my_script.rb -h

You will obtain a nice command line help:

```
Usage: my_script [options]
My super application Version: 0.0.1

This application is a proof of concept for EasyAppHelper.
-- Generic options -------------------------------------------------------------
        --auto                 Auto mode. Bypasses questions to user.
        --simulate             Do not perform the actual underlying actions.
    -v, --verbose              Enable verbose mode.
    -h, --help                 Displays this help.
-- Configuration options -------------------------------------------------------
        --config-file          Specify a config file.
        --config-override      If specified override all other config.
-- Debug and logging options ---------------------------------------------------
        --debug                Run in debug mode.
        --debug-on-err         Run in debug mode with output to stderr.
        --log-level            Log level from 0 to 5, default 2.
        --log-file             File to log to.
-- My script options -----------------------------------------------------------
    -u, --useless              Stupid option
        --anint                Stupid option with integer argument
```

See [stacked_config Gem][SC] documentation for more options.


## Compatibility issues with previous versions

### With version 2.x

The meaning of the `gem_layer` changed between version 3.x and 2.x (see [stacked_config][SC] which introduced this in
version 1.x). It has been basically replaced by the `executable_gem_layer`.

For standard easy_app_helper usage it should not change anything.

### With version 1.x

[easy_app_helper][EAH] v2.x is not fully compatible with previous branch 1.x. But for common usage it should
nevertheless be the case.

There is a (not perfect) compatibility mode that you can trigger by setting the `easy_app_helper_compatibility_mode`
property to true in one of your config files.

## Generate scripts using rake task

### Including easy_app_helper tasks in your own gems.

For this you just need to include in your own gem `Rakefile`:

```ruby
require 'easy_app_helper/tasks'
```
This will add two extra rake tasks to your gem. Normally if you created correctly your gem (`bundle gem my_gem`), you
already have 3 tasks existing coming from the `require "bundler/gem_tasks"` that you probably have in your default
Rakefile. Now will get something like this instead:

```shell
$ bundle exec rake -T
rake build                                               # Build your_gem-0.0.1.gem into the pkg directory
rake easy_app_helper:create_executable[executable_name]  # create automatically a new executable in "bin" from a template
rake easy_app_helper:show_template                       # Displays the template used
rake install                                             # Build and install your_gem-0.0.1.gem into system gems
rake release                                             # Create tag v0.0.1 and build and push your_gem-0.0.1.gem to Rubygems
```
The two [easy_app_helper][EAH] tasks are quite self-explanatory.

### Generating script templates for your project

Basically you will do a:

    $ bundle exec rake easy_app_helper:create_executable

And it will reply something like:

```
File '/home/you/devel/ruby/gems/your_gem/bin/your_gem' created with execution rights.
 -> Try: "bundle exec '/home/you/devel/ruby/gems/your_gem/bin/your_gem' --help"
```

By default, the rake task will create a executable with the name of the gem you are currently developing.
__This task is safe and will never overwrite an existing file__. Instead, if the file already exists, you would get:

```
File '/home/you/devel/ruby/gems/your_gem/bin/your_gem' already exists !
 -> Aborted.
```

You can, of course, specify your own file name to the rake task. Depending on your shell, and due to different
variable expansion mechanisms, you have to do it differently:

* __zsh__ should be something like: `bundle exec rake easy_app_helper:create_executable\[my_executable\]`
* whereas in __bash__ more probably: `bundle exec rake easy_app_helper:create_executable[my_executable]`

Check the documentation of your shell for further information.
You should nevertheless have this kind of answer from the task:

```
File '/home/you/devel/ruby/gems/your_gem/bin/my_executable' created with execution rights.
 -> Try: "bundle exec '/home/you/devel/ruby/gems/your_gem/bin/my_executable' --help"
```

You can notice the slight changes in terms of code in the two generated scripts ;-). Check the template with
`bundle exec rake easy_app_helper:show_template` to understand how the template adapts.


## Complete example of a script based on `easy_app_helper`

This is not exactly what is generated by the rake task (which is more up-to-date), but gives an overall idea:

```ruby
#!/usr/bin/env ruby

require 'easy_app_helper'

class MyApp

  include EasyAppHelper

  VERSION = '0.0.1'
  NAME = 'My brand new Application'
  DESCRIPTION = 'Best app ever'

  def initialize
    config.config_file_base_name = 'basename_for_my_config_files' # Default is the name of this script (w/o extensions)
    config.describes_application app_name: NAME,
                                 app_version: VERSION,
                                 app_description: DESCRIPTION
    add_script_options
  end

  def add_script_options
    config.add_command_line_section('Options for the script') do |slop|
      slop.on :u, :useless, 'Stupid option', :argument => false
      slop.on :an_int, 'Stupid option with integer argument', :argument => true, :as => Integer
    end
  end

  def run
    # An example of testing a command line option
    config[:an_int] ||= 10

    # Displaying command line help
    if config[:help]
      puts config.command_line_help
      exit 0
    end

    begin
      do_some_processing
    rescue => e
      puts "Program aborted with message: '#{e.message}'."
      if config[:debug]
        logger.fatal "#{e.message}\nBacktrace:\n#{e.backtrace.join("\n\t")}"
      else
        puts '  Use --debug option for more detail.'
      end
    end
  end

  def do_some_processing
    # Here you would really start your process
    puts_and_logs 'Starting processing'
    config[:something] = 'Added something...'

    # When in debug mode, will log the config used by the application
    logger.debug config[].to_yaml

    if config[:verbose]
      puts ' ## Here is a display of the config sources and contents'
      puts config.detailed_layers_info
      puts ' ## This the resulting merged config'
      puts config[].to_yaml
    end
  end

end

MyApp.new.run
```

## Contributing

1. [Fork it] ( https://github.com/lbriais/easy_app_helper/fork ), clone your fork.
2. Create your feature branch (`git checkout -b my-new-feature`) and develop your super extra feature.
3. Commit your changes (`git commit -am 'Add some feature'`).
4. Push to the branch (`git push origin my-new-feature`).
5. Create a Pull Request.


__That's all folks.__


[EAH]:  https://rubygems.org/gems/easy_app_helper                           "EasyAppHelper gem"
[EAH1]: https://github.com/lbriais/easy_app_helper/tree/old_release_1_x     "EasyAppHelper gem DEPRECATED branch"
[SC]:   https://github.com/lbriais/stacked_config                           "The stacked_config Gem"
