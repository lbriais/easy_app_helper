#-------------------------------------------------------------------------------
#  
#
# Copyright (c) 2013 L.Briais under MIT license
# http://opensource.org/licenses/MIT
#-------------------------------------------------------------------------------

require 'rspec'
require 'easy_app_helper'


#describe EasyAppHelper::Core::Config do
describe "The EasyAppHelper config object" do
  SAMPLE_STRING = 'TestConfig'
  subject {EasyAppHelper.config}


  it 'should be fully initialized when first accessed' do
    subject.should_not be nil
    subject.logger.should_not be nil
  end

  it 'should be consistent regardless the way it is accessed' do
    subject[:basic_test] = SAMPLE_STRING
    expect(subject[]).to eq subject.to_hash
    expect(subject[:basic_test]).to eq SAMPLE_STRING
  end

  it 'should be the same object accross different instances' do
    expect(subject[:basic_test]).to eq SAMPLE_STRING
  end

  it 'should store the data in the :modified layer' do
    expect(subject.find_layer :basic_test).to eq :modified
    expect(subject.internal_configs[:modified][:content][:basic_test]).to eq subject[:basic_test]
  end

  it 'should provide a direct r/w access to layers' do
    subject.set_value :stupid_conf, SAMPLE_STRING, :system
    expect(subject[:stupid_conf]).to eq SAMPLE_STRING
  end

  it 'should be reloaded when :config-file property changes' do
    subject.should_receive(:force_reload)
    subject[:'config-file'] = SAMPLE_STRING
  end

  it 'should be reloaded when script_filename changes' do
    subject.should_receive(:force_reload)
    subject.script_filename = SAMPLE_STRING
  end


  context 'when dealing with the multiple layers of the config' do

    before(:all) do
      EasyAppHelper.config.layers.each do |layer|
        EasyAppHelper.config.set_value :basic_test, "#{SAMPLE_STRING} #{layer.to_s}", layer
      end
      EasyAppHelper.config.set_value :'config-file', true, :command_line
    end

    context "when trying to access some data" do
      let(:layers) {subject.layers}
      #subject {EasyAppHelper.config}

      original_ordered_layers = EasyAppHelper.config.layers
      layers = original_ordered_layers.dup
      original_ordered_layers.each do |layer|
        test_descr = "It should find the data in #{layer} layer if present in #{layer} layer"
        unless layers.length == original_ordered_layers.length
          already_removed = original_ordered_layers - layers
          if already_removed.length == 1
            test_descr += " and not present in #{already_removed[0]} layer"
          end
          if already_removed.length > 1
            test_descr += " and not present in #{already_removed.join ', '} layers"
          end
        end

        it test_descr, layers: layers.dup  do
          layers = example.metadata[:layers]
          expect(subject.find_layer :basic_test).to eq layer
          expect(subject[:basic_test]).to eq "#{SAMPLE_STRING} #{layer.to_s}"
          subject.internal_configs[layer][:content].delete :basic_test
        end

        layers.shift

      end
    end

    context "when manually introducing a layer" do

      it "should be handled with the lowest priority" do
        subject.set_value :unused_option, SAMPLE_STRING, :non_existing_layer
        expect(subject[:unused_option]).to eq SAMPLE_STRING
        subject.set_value :unused_option, 'Not the sample string', :system
        expect(subject[:unused_option]).to_not eq SAMPLE_STRING
      end

    end



  end

  context "when reset" do

    it "should remove all modifications done the standard way" do
      subject[:test_remove] = SAMPLE_STRING
      subject.reset
      expect(subject[:test_remove]).to be_nil
    end

    it "should keep modifications directly done on internal layers" do
      subject.set_value :stupid_conf, SAMPLE_STRING, :system
      subject.reset
      expect(subject.get_value :stupid_conf, :system).to eq SAMPLE_STRING
    end

  end

  context "when reloaded" do

    it "should keep all modifications done the standard way" do
      subject[:test_remove] = SAMPLE_STRING
      subject.load_config
      expect(subject[:test_remove]).to eq SAMPLE_STRING
    end

    it "should remove all modifications directly done on internal layers" do
      subject.set_value :stupid_conf, SAMPLE_STRING, :system
      subject.set_value :stupid_conf, SAMPLE_STRING, :command_line
      subject.load_config
      expect(subject.get_value :stupid_conf,:system).to be_nil
      expect(subject.get_value :stupid_conf,:command_line).to be_nil
    end

  end

  context "when reloaded (forced)" do

    it "should keep all modifications done the standard way" do
      subject[:test_remove] = SAMPLE_STRING
      subject.force_reload
      expect(subject[:test_remove]).to eq SAMPLE_STRING
    end

    it "should remove all modifications directly done on internal layers" do
      subject.set_value :stupid_conf, SAMPLE_STRING, :system
      subject.set_value :stupid_conf, SAMPLE_STRING, :command_line
      subject.force_reload
      expect(subject.get_value :stupid_conf,:system).to be_nil
      expect(subject.get_value :stupid_conf,:command_line).to be_nil
    end

  end


  context "When dealing with command line" do

    it 'should have the same content using #command_line_config and #internal_configs[:command_line][:content]' do
      subject.add_command_line_section('Scripts analysis') do |slop|
        slop.on :p, :pipo, 'Directory path where SQL files are located.', argument: false
      end
      expect(subject.command_line_config).to eq subject.internal_configs[:command_line][:content]
    end

  end

end