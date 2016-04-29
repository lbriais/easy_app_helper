require 'spec_helper'

describe EasyAppHelper::Processes::Base do

  subject {described_class.new}

  before(:all) do
    EasyAppHelper.config[:debug] = true
    EasyAppHelper.config[:'log-level'] = 0
    io = IO.new File.open('/tmp/pipo.log', 'w').fileno
    io.sync
    EasyAppHelper::Logger::Initializer.setup_logger Logger.new(io)
    EasyAppHelper.logger.info 'Hi World'
  end

  it 'should be a synchronous job by default' do
    expect(subject.mode).to eq :synchronous
  end

  context 'when the command is invalid' do
    let (:command) {'blablabla'}
    subject {described_class.new command}

    it 'should raise an exception' do
      expect { subject.execute }.to raise_error
    end

  end

  context 'when the command can execute and returns a status' do

    let (:true_command) { 'true' }
    let (:false_command) { 'false' }

    it 'should capture the command exit status' do
      subject.command = true_command
      expect(subject.execute.success?).to be_truthy
      subject.command = false_command
      expect(subject.execute.success?).to be_falsey
    end

    it 'should have a valid duration' do
      subject.command = true_command
      expect(subject.creation_time).not_to be_nil
      expect(subject.start_time).to be_nil
      expect(subject.end_time).to be_nil
      subject.execute
      expect(subject.start_time).not_to be_nil
      expect(subject.end_time).not_to be_nil
      expect(subject.duration).to be > 0
    end

  end

  context 'when executing a job that has "out" and "err" outputs' do

    let (:command_with_out) {File.expand_path('../../../test/process/test.sh', __FILE__)}

    it 'should capture everything' do
      subject.command = command_with_out
      subject.show_output = true
      expect(STDOUT).to receive(:puts).exactly(2).times
      expect(STDERR).to receive(:puts).exactly(2).times
      subject.execute
    end


  end

end