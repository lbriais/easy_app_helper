require 'spec_helper'


describe EasyAppHelper.config do

  it 'should be accessible as a module method' do
    expect(EasyAppHelper.config).to be_a_kind_of StackedConfig::Orchestrator
  end

  context 'when mixing-in the EasyAppHelper module' do

    it 'should be accessible as a direct method' do
      class A
        include EasyAppHelper
      end
      a = A.new
      expect(a.respond_to? :config).to be_truthy
      expect(a.config == EasyAppHelper.config).to be_truthy
    end

  end
end