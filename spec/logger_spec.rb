require 'spec_helper'


describe EasyAppHelper.logger do

  it 'should be a valid logger' do
    expect(subject).to be_a_kind_of ::Logger
  end

  it 'should respond to :puts_and_logs' do
    expect(subject).to respond_to :puts_and_logs
  end


end