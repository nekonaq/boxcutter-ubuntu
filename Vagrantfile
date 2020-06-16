# coding: utf-8
# -*- mode: ruby -*-

Vagrant.configure("2") do |nodes|

  nodes.vm.define 'boxinst' do |config|
    config.vm.box = "custom/ubuntu1804-18.04.4.2007.4"
    # config.vm.box_check_update = false

    config.vm.hostname = 'boxinst'
    config.vm.provider "virtualbox" do |vb|
      vb.name = 'boxinst'
      vb.memory = "2048"
      # vb.gui = true
    end

    config.vm.network 'private_network', ip: '192.168.8.247',
                      auto_config: true

    config.vm.network :forwarded_port, id: 'ssh', 
                      guest: 22, host: 2204,  # デフォルトは 2222
                      auto_correct: true

    config.vm.synced_folder '.', '/vagrant', type: 'virtualbox'

    if Vagrant.has_plugin?('vagrant-vbguest')
      config.vbguest.auto_update = true
    end
  end
end
