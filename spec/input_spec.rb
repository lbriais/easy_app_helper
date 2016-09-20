require 'spec_helper'


describe EasyAppHelper::Input do

  subject {
    o = Object.new.extend EasyAppHelper::Input
    o
  }

  it 'should prompt user for confirmation' do
    described_class::DEFAULT_CONFIRMATION_CHOICES.each_pair do |expected_result, choices|
      choices.each do |choice|
        expect(STDOUT).to receive(:print)
        expect(STDIN).to receive(:gets).and_return(choice)
        expect(subject.get_user_confirmation).to be expected_result
      end
    end
  end

  context 'when not in strict mode' do

    it 'should default to default choice if bullshit is entered' do
      expect(STDOUT).to receive(:print)
      expect(STDIN).to receive(:gets).and_return('bullshit')
      expect(subject.get_user_confirmation).to be false
    end

  end

  context 'when in strict mode' do

    it 'should re-ask until bullshit is not entered' do
      expect(STDOUT).to receive(:print)
      expect(STDIN).to receive(:gets).and_return('bullshit')
      expect(STDIN).to receive(:gets).and_return('bullshit')
      expect(STDIN).to receive(:gets).and_return('bullshit')
      expect(STDIN).to receive(:gets).and_return('y')
      expect(subject.get_user_confirmation strict: true).to be true
    end

  end

  context 'when user passes --auto to command line' do

    it 'should bypass the question and return true' do
      expect(EasyAppHelper.config).to receive(:[]).with(:auto).and_return(true)
      expect(subject.get_user_confirmation).to be true
    end


  end


end