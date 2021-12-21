---
title: 「Kubernetes 實作手冊：基礎入門篇」學習筆記（一）：虛擬環境建置
permalink: 「Kubernetes-實作手冊：基礎入門篇」學習筆記（一）：虛擬環境建置
date: 2021-12-05 15:26:20
tags: ["環境部署", "Kubernetes", "Docker"]
categories: ["環境部署", "Kubernetes", "「Kubernetes 實作手冊：基礎入門篇」學習筆記"]
---

## 前言

本文為「Kubernetes 實作手冊：基礎入門篇」課程的學習筆記。

## 環境建置

下載課程所需要使用的檔案。

```BASH
git clone https://github.com/hwchiu/hiskio-course.git
```

進入到 `vagrant` 資料夾，檢查 `Vagrantfile` 檔：

```YAML
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-18.04"
  config.vm.box_version ='201912.14.0'
  config.vm.hostname = 'k8s-dev'
  config.vm.define vm_name = 'k8s'

  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    set -e -x -u
    export DEBIAN_FRONTEND=noninteractive

    #change the source.list
    sudo apt-get update
    sudo apt-get install -y vim git cmake build-essential tcpdump tig jq socat bash-completion
    # Install Docker
    export DOCKER_VERSION="5:19.03.5~3-0~ubuntu-bionic"
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get update
    sudo apt-get install -y docker-ce=${DOCKER_VERSION}
    sudo usermod -aG docker $USER

    #Disable swap
    #https://github.com/kubernetes/kubernetes/issues/53533
    sudo swapoff -a && sudo sysctl -w vm.swappiness=0
    sudo sed '/vagrant--vg-swap/d' -i /etc/fstab

    git clone https://github.com/hwchiu/hiskio-course.git

    git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it
    bash ~/.bash_it/install.sh -s

  SHELL

  config.vm.network :private_network, ip: "172.17.8.111"
  config.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--cpus", 2]
      v.customize ["modifyvm", :id, "--memory", 4096]
      v.customize ['modifyvm', :id, '--nicpromisc1', 'allow-all']
  end
end
```

執行以下指令，啟動一個虛擬機器。

```BASH
vagrant up
```

Vagrant 會根據 `Vagrantfile` 檔，呼叫 VirtualBox 去建置一個虛擬機器。

```BASH
Bringing machine 'k8s' up with 'virtualbox' provider...
```

如果出現以下錯誤訊息，則需要修改 `Vagrantfile` 檔中的 IP 位址（例如 `192.168.56.231`）：

```BASH
The IP address configured for the host-only network is not within the

allowed ranges. Please update the address used to be within the allowed

ranges and run the command again.

  Address: 172.17.8.111

  Ranges: 192.168.56.0/21
```

如果要進到虛擬機器中，使用以下指令。

```BASH
vagrant ssh
```

如果要關閉虛擬機器，使用以下指令。

```BASH
vagrant halt
```

如果要銷毀虛擬機器，使用以下指令。

```BASH
vagrant destroy
```

## 參考資料

- [Kubernetes 實作手冊：基礎入門篇](https://hiskio.com/courses/349/about)
