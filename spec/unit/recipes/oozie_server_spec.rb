#
# Cookbook Name:: sncr_mapr
# Spec:: default
#
# Copyright (c) 2016 Synchronoss Technologies, Inc., All Rights Reserved.

require 'spec_helper'

describe 'sncr_mapr::oozie_server' do
  context 'When all attributes are default, on an unspecified platform' do
    let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

    it 'converges successfully' do
      chef_run # This should not raise an error
    end
  end
end
