require 'erb'
require 'active_support/core_ext/string/inflections'

module EasyAppHelper
  module Tasks

    module TemplateManager

      attr_reader :executable_name, :gem_module, :gem_name, :current_date, :script_class, :task

      TEMPLATE = File.expand_path '../template.rb.erb', __FILE__

      def get_template
        File.read TEMPLATE
      end

      def check_bin_dir
        spec = current_gem_spec
        rel_bin_dir = spec.bindir.empty? ? 'bin' : spec.bindir
        bin_dir = File.join task.application.original_dir, rel_bin_dir
        FileUtils.mkdir bin_dir unless Dir.exists? bin_dir
        bin_dir
      end

      def build_executable(executable_name=current_gem_name)
        executable_name ||= current_gem_spec.name
        @executable_name = executable_name
        @gem_name = current_gem_spec.name
        @gem_module = @gem_name.camelize
        @current_date = Time.now.strftime('%c')
        @script_class = executable_name == current_gem_spec.name ? '' : executable_name.camelize
        @script_class << 'Script'
        renderer = ERB.new(File.read(TEMPLATE), nil, '-')
        renderer.result binding
      end

      def current_gem_spec
        searcher = if Gem::Specification.respond_to? :find
                     # ruby 2.0
                     Gem::Specification
                   elsif Gem.respond_to? :searcher
                     # ruby 1.8/1.9
                     Gem.searcher.init_gemspecs
                   end
        unless searcher.nil?
          searcher.find do |spec|
            original_file = task ? File.join(task.application.original_dir, task.application.rakefile) : __FILE__
            File.fnmatch(File.join(spec.full_gem_path,'*'), original_file)
          end
        end
      end


    end

  end
end
