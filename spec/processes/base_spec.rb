require 'spec_helper'

describe EasyAppHelper::Processes::Base do

  before(:all) do
    # EasyAppHelper::Logger::Initializer.setup_logger Logger.new(STDOUT)
    EasyAppHelper.config[:'log-level'] = 0
    EasyAppHelper.config[:debug] = true
    EasyAppHelper.config[:'log-file'] = '/tmp/pipo.log'

  end


  let (:long_running_command) {'ls -l /'}
  subject {described_class.new long_running_command}


  it 'should return the exit status' do
    expect(subject.execute.success?).to be_truthy
  end

  it 'should execute the command and run ' do
    res = subject.execute
    p res
  end

end