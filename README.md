Installation
============

The requirement is the "vagrant" system, which you install on ubuntu via
sudo apt-get install vagrant (I used version 1:1.7.2)

Then you check out the MassBank-web project, 
(or fork on github first and clone from your own repository)

which contains 1) The virtual machine initialization files 
Vagrantfile and bootstrap.sh and 2) the MassBank software 
to be installed inside the virtual machine. 

After cloning the repo, the create the virtual machine 
and fire it up in virtualbox. Once everything finished, 
you  should have a running MassBank, so point your browser 
to http://192.168.35.18/MassBank/ You can also ssh into 
the virtual machine without password:

````
git clone https://github.com/MassBank/MassBank-web
cd MassBank-web 
vagrant up
vagrant ssh
````


## Fedora 22 Workstation

Install vagrant

````
sudo dnf install vagrant
````
According to [this](https://unix.stackexchange.com/questions/194691/use-virtualbox-provider-by-default-on-fedora-21) StackExchange post, Fedora is not using VirtualBox as a default provider.
When geting the follwoing error:

````
The provider 'libvirt' could not be found, but was requested to
back the machine 'default'. Please use a provider that exists.
````
Execute the these two steps:
````
$ echo "export VAGRANT_DEFAULT_PROVIDER=virtualbox" >> ~/.zshr
$ source ~/.zshrc
`````
The vagrant version from the repository (Version 1.7.2) does NOT support Virtualbox Version 5




