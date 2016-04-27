require 'spec_helper'


describe EasyAppHelper do

  let (:message) { :a_message }
  subject {described_class}

  %i(config logger puts_and_logs safely_exec_code safely_exec_command).each do |m|
    it "should have a :#{m.to_s} module method" do
      expect(subject).to respond_to m
    end
  end

  context 'when mixing-in the EasyAppHelper module' do
    subject {
      class A
        include EasyAppHelper
      end
      A.new
    }

    %i(config logger puts_and_logs safely_exec_code safely_exec_command).each do |m|
      it "should have a :#{m.to_s} method " do
        expect(subject).to respond_to m
      end

    end

  end

  it 'should allow to safely execute a block' do
    expect do
      subject.safely_exec_code message do
        raise
      end
    end.to raise_error

    subject.config[:simulate] = true
    expect do
      subject.safely_exec_code message do
        raise
      end
    end.not_to raise_error

  end


end
