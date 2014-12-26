require 'spec_helper'


describe EasyAppHelper.config do

  it 'should be a StackedConfig::Orchestrator' do
    expect(subject).to be_a_kind_of StackedConfig::Orchestrator
  end

  it 'should respond to safely_exec' do
    expect(subject).to respond_to :safely_exec
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