require 'spec_helper'


describe EasyAppHelper.config do

  it 'should be a StackedConfig::Orchestrator' do
    expect(subject).to be_a_kind_of StackedConfig::Orchestrator
  end


  it 'should have the compatibility mode set if :easy_app_helper_compatibility_mode is set in the config' do
    expect(subject).to_not respond_to :help
    expect(subject).to_not respond_to :command_line_config
    EasyAppHelper::Config.set_compatibility_mode subject
    expect(subject).to respond_to :help
    expect(subject).to respond_to :command_line_config
  end

  context 'when mixing-in the EasyAppHelper module' do
    subject {
      class A
        include EasyAppHelper
      end
      A.new
    }
    it 'should be the exact same object' do
      expect(subject.config.equal? EasyAppHelper.config).to be_truthy
    end

  end
end