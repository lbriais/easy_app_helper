require 'erb'
require 'active_support/core_ext/string/inflections'

module EasyAppHelper
  module Tasks

    module TemplateManager

      attr_reader :executable_name, :gem_module, :gem_name, :current_date, :script_class

      TEMPLATE = File.expand_path '../template.rb.erb', __FILE__

      def get_template
        File.read TEMPLATE
      end

      def build_executable(executable_name=current_gem_name)
        @executable_name = executable_name
        @gem_name = current_gem_name
        @gem_module = @gem_name.camelize
        @current_date = Time.now.strftime('%c')
        @script_class = executable_name == current_gem_name ? '' : executable_name.camelize
        @script_class << 'Script'
        renderer = ERB.new(File.read TEMPLATE)
        puts renderer.result binding

      end

      def current_gem_name
        searcher = if Gem::Specification.respond_to? :find
                     # ruby 2.0
                     Gem::Specification
                   elsif Gem.respond_to? :searcher
                     # ruby 1.8/1.9
                     Gem.searcher.init_gemspecs
                   end
        spec = unless searcher.nil?
                 searcher.find do |spec|
                   File.fnmatch(File.join(spec.full_gem_path,'*'), __FILE__)
                 end
               end
        spec.name
      end

    end
  end
end