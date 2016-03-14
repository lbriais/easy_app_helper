require 'spec_helper'

describe EasyAppHelper::Processes::Base do

  before(:all) do
    # EasyAppHelper::Logger::Initializer.setup_logger Logger.new(STDOUT)
    EasyAppHelper.config[:'log-level'] = 0
    EasyAppHelper.config[:debug] = true
    EasyAppHelper.config[:'log-file'] = '/tmp/pipo.log'

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
    subject {described_class.new}

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

end