require 'spec_helper'


describe EasyAppHelper do

  %i(config logger puts_and_logs safely_exec).each do |m|
    it "should have module method #{m.to_s}" do
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

    %i(config logger puts_and_logs safely_exec).each do |m|
      it "should have a #{m.to_s} method " do
        expect(subject).to respond_to m
      end

    end

  end
end
