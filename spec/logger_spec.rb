require 'spec_helper'


describe EasyAppHelper.logger do

  it 'should be a valid logger' do
    expect(subject).to be_a_kind_of ::Logger
  end

end