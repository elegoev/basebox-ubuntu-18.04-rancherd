# create git tag

$src_image_version = $env:IMAGE_VERSION

$vagrant_file_template = '
Vagrant.configure("2") do |config|

  $basebox_name="ubuntu-18.04-rancherd-test"
  $basebox_hostname="ubuntu-1804-rancherd-test"
  $src_image_name="elegoev/ubuntu-18.04-rancherd"
  $vb_group_name="basebox-rancherd-test"

  config.vm.define "#{$basebox_name}" do |machine|
    machine.vm.box = "#{$src_image_name}"
    machine.vm.box_version = "$image_version"
    
    # define guest hostname
    machine.vm.hostname = "#{$basebox_hostname}"

    machine.vm.provider "virtualbox" do |vb|
      vb.name = $basebox_name
      vb.cpus = 1
      vb.customize ["modifyvm", :id, "--memory", "1024" ]
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
      vb.customize ["modifyvm", :id, "--uartmode1", "disconnected" ]
      vb.customize ["modifyvm", :id, "--groups", "/#{$vb_group_name}" ]
      vb.customize ["modifyvm", :id, "--vram", 256 ]
    end
  
    # forwarding ports
    machine.vm.network "forwarded_port", id: "rancher-ssl",  auto_correct: true, protocol: "tcp", guest: 8443, host: 8443, host_ip: "127.0.0.1"

    machine.trigger.after :destroy do |trigger|
      trigger.info = "Cleanup environment"
      trigger.run = {path: "./cleanup-vagrant.ps1"}  
    end

  end   

end
'

# create Vagrantfile for download test
$vagrant_file_expanded = $vagrant_file_template.Replace('$image_version', "$src_image_version")
Set-Content -Path './test/download/Vagrantfile' -Value "$vagrant_file_expanded"

# create git tag
git add --all
git commit -m "new basebox version $src_image_version"
git push 
git tag $src_image_version
git push --tags





