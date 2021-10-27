resource "aws_instance" "minecraft_server" {
    /*
    t3.large -> can support ~ 80 users
    however, if you don't set world bounds
    and players have high dispersion you may
    run out of ram - if you need to upgrade
    i'd stick with a 2 vCPU server. Minecraft
    Java is single threaded so it will hog one
    vCPU - the other will give some breathing room
    to the other processes we'll be running
    General rule of thumb is 9 users / 1gb ram 
    (if you have a *heavily* modded server this 
    ratio will be lower)

    Sidenote - changing instance_type will also
    require you to change -Xmx -Xms flags in user
    data file below
    */
    instance_type               = "t3.large"
    ami                         = "${data.base_image.ubuntu.id}"
    key_name                    = "${var.key_pair_name}"
    associate_public_ip_address = true
    monitoring                  = true
    ebs_optimized               = true

    ebs_block_device = {
        device_name           = "${var.project_name}-server-host-volume"
        volume_size           = 100
        encrypted             = true
        delete_on_termination = false
        tags                  = {
            Name = "${var.project_name}-ebs-hot-volume"
        }
    }

  
    /*
    Ensures that new server is created before previous one
    shuts down if you update anything that leads to a new
    resource having to be created - if you don't want 
    this behavior and want to make it impossible for any changes
    to accidentally overwrite switch to create_before_destroy to
    prevent_destroy
    */
    lifecycle {
        create_before_destroy = true
    }

    # Startup script for starting and managing minecraft server
    user_data = <<-EOF
    #!/bin/bash
    sudo apt -y update
    sudo apt -y install git build-essential
    
    echo "Installing JDK"
    sudo apt install -y openjdk-16-jdk-headless
    sudo zypper in java-1_8_0-openjdk

    echo "Creating minecraft user"
    sudo useradd -r -m -U -d /opt/minecraft -s /bin/bash minecraft

    echo "Installing minecraft"
    sudo su - minecraft
    mkdir -p ~/{backups,tools,server}

    git clone https://github.com/Tiiffi/mcrcon.git ~/tools/mcrcon

    cd ~/tools/mcrcon
    gcc -std=gnu11 -pedantic -Wall -Wextra -O2 -s -o mcrcon mcrcon.c

    cd ~/server
    wget https://launcher.mojang.com/v1/objects/a16d67e5807f57fc4e550299cf20226194497dc2/server.jar

    echo "Creating minecraft server"
    java -Xmx6G -Xms2G -jar minecraft_server.1.17.1.jar nogui
    sed -i 's/eula=false/eula=true/' eula.txt
    sed -i 's/rcon.password=/rcon.password=${var.rcon_password}/' server.properties
    sed -i 's/enable-rcon=false/enable-rcon=true' server.properties


    # https://minecraft.fandom.com/wiki/Tutorials/Ubuntu_startup_script
    echo "[Unit]
    Description=Minecraft Server
    After=network.target

    [Service]
    user=minecraft
    Nice=1
    KillMode=none
    ProtectHome=true
    ProtectSystem=full
    PrivateDevices=true
    NoNewPrivileges=true
    SuccessExitStatus=0 1
    InaccessibleDirectories=/root /sys /srv /media -/lost+found
    WorkingDirectory=/opt/minecraft/server
    ReadWriteDirectories=/opt/minecraft/server
    ExecStart=/usr/bin/java -Xmx6G -Xms2G -jar minecraft_server.1.17.1.jar nogui 
    ExecStop=/opt/minecraft/tools/mcrcon/mcrcon -H 127.0.0.1 -P 25575 -p strong-password stop
    Restart=on-failure
    RestartSec=20 5

    [Install]
    WantedBy=multi-user.target
    " >> /etc/systemd/system/minecraft.service

    su

    sudo chmod 664 /etc/systemd/system/minecraft.service
    systemctl daemon-reload

    echo "Starting minecraft server"
    sudo systemctl start minecraft

    echo "Setting minecraft server to start at boot time"
    sudo systemctl enable minecraft

    echo "Opening up server to outside traffice"
    sudo ufw allow 25565/tcp



    EOF
    
    tags = {
        Name = "${var.project_name}-ec2-instance"
    }
}

data "base_image" "ubuntu" {
        most_recent = true
        owners      = ["099720109477"] 

        filter {
            name = "name"
            values = "[ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*]"
        }

        filter {
            name    = "virtualization-type"
            values  = "hvm"
        }
    }
