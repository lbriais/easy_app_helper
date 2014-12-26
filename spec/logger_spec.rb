require 'spec_helper'


describe EasyAppHelper.logger do

  it 'should have a puts_and_logs method' do
    expect(subject.respond_to? :puts_and_logs).to be_truthy
  end

  it 'should be a valid logger' do
    expect(subject).to be_a_kind_of ::Logger
  end

  context ''

end