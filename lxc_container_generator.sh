#!/bin/bash
if [ $UID != 0 ]
then
    echo "Execute this script with root privileges!"
    exit 1
fi

while(true)
do
    clear
    read -p "How many LXC Containers do you want to create?: " lxc_amount
    read -p "What name should the containers have? (e.g: Container [A number is set as suffix]): " lxc_name
    echo "[altlinux, archlinux, debconf, debconf.d, debian, fedora, opensuse, progress, progress.d, sshd, ubuntu-cloud]"
    read -p "What Linux distribution do you want to install?: " lxc_distribution
    read -p "Enter the path where the LXC Containers are saved: " lxc_container_path
    echo "[bridge, nat]"
    read -p "Choose between bridged or natted network for the containers: " bridge_nat
    read -p "Enter the IP address of the containers (e.g: 192.168.2.5 [They will be itereated by 1]): " lxc_ip
    read -p "Enter the Default Gateway for each container (e.g: 192.168.2.1): " lxc_gateway
    
    clear
    echo "You entered the follwing:"
    echo ""
    echo ""
    echo "Amount of LXC Containers: $lxc_amount"
    echo ""
    echo "Container Name/s:"

    for i in `seq $lxc_amount`
    do
        echo $lxc_name$i
    done

    echo ""
    echo "Distribution to install: $lxc_distribution"
    echo ""
    echo "LXC Container path: $lxc_container_path"
    echo ""
    echo "Network Type: $bridge_nat"
    echo ""
    echo "Container IP address/es:"

    lxc_ip_address=`echo $lxc_ip | awk -F "." '{print $1"."$2"."$3"."}'` 
    lxc_ip_address_fourth_octette=`echo $lxc_ip | awk -F "." '{print $4}'`

    for j in `seq $lxc_amount`
    do
        echo $lxc_ip_address$lxc_ip_address_fourth_octette
        (( lxc_ip_address_fourth_octette++ ))
    done

    echo ""
    echo "Container gateway address: $lxc_gateway" 
    echo ""

    read -p "Do you want to create these containers? (y/n) " continue

    if [ $continue == "y" ]
    then
        lxc_ip_address_fourth_octette=`echo $lxc_ip | awk -F "." '{print $4}'`

        for k in `seq $lxc_amount`
        do
            lxc-create -n $lxc_name$k -t $lxc_distribution
            
            echo "" >> "$lxc_container_path/$lxc_name$k/config"
            echo "# Network Settings" >> "$lxc_container_path/$lxc_name$k/config"
            
            if [ $bridge_nat == "bridge" ]
            then
                echo "# Bridge" >> "$lxc_container_path/$lxc_name$k/config"
                echo "lxc.network.type = veth" >> "$lxc_container_path/$lxc_name$k/config"
                echo "lxc.network.flags = up" >> "$lxc_container_path/$lxc_name$k/config"
                echo "lxc.network.link = lxc-bridge" >> "$lxc_container_path/$lxc_name$k/config"
                echo "lxc.network.name = lxceth0" >> "$lxc_container_path/$lxc_name$k/config"
                echo "#lxc.network.hwaddr = 12:34:56:78:9A:BC" >> "$lxc_container_path/$lxc_name$k/config"
                echo "lxc.network.ipv4 = $lxc_ip_address$lxc_ip_address_fourth_octette" >> "$lxc_container_path/$lxc_name$k/config"
                echo "lxc.network.ipv4.gateway = $lxc_gateway" >> "$lxc_container_path/$lxc_name$k/config"

                echo "" >> "$lxc_container_path/$lxc_name$k/config"
                echo "# NAT" >> "$lxc_container_path/$lxc_name$k/config"
                echo "#lxc.network.type = veth" >> "$lxc_container_path/$lxc_name$k/config"
                echo "#lxc.network.flags = up" >> "$lxc_container_path/$lxc_name$k/config"
                echo "#lxc.network.link = lxc-bridge-nat" >> "$lxc_container_path/$lxc_name$k/config"
                echo "#lxc.network.name = lxceth0" >> "$lxc_container_path/$lxc_name$k/config"
                echo "#lxc.network.hwaddr = 12:34:56:78:9A:BC" >> "$lxc_container_path/$lxc_name$k/config"
                echo "#lxc.network.ipv4 = 192.168.1.$lxc_ip_address_fourth_octette" >> "$lxc_container_path/$lxc_name$k/config"
                echo "#lxc.network.ipv4.gateway = $lxc_gateway" >> "$lxc_container_path/$lxc_name$k/config"
                (( lxc_ip_address_fourth_octette++ ))

            else
                echo "# Bridge" >> "$lxc_container_path/$lxc_name$k/config"
                echo "#lxc.network.type = veth" >> "$lxc_container_path/$lxc_name$k/config"
                echo "#lxc.network.flags = up" >> "$lxc_container_path/$lxc_name$k/config"
                echo "#lxc.network.link = lxc-bridge" >> "$lxc_container_path/$lxc_name$k/config"
                echo "#lxc.network.name = lxceth0" >> "$lxc_container_path/$lxc_name$k/config"
                echo "#lxc.network.hwaddr = 12:34:56:78:9A:BC" >> "$lxc_container_path/$lxc_name$k/config"
                echo "#lxc.network.ipv4 = $lxc_ip_address$lxc_ip_address_fourth_octette" >> "$lxc_container_path/$lxc_name$k/config"
                echo "#lxc.network.ipv4.gateway = $lxc_gateway" >> "$lxc_container_path/$lxc_name$k/config"

                echo "" >> "$lxc_container_path/$lxc_name$k/config"
                echo "# NAT" >> "$lxc_container_path/$lxc_name$k/config"
                echo "lxc.network.type = veth" >> "$lxc_container_path/$lxc_name$k/config"
                echo "lxc.network.flags = up" >> "$lxc_container_path/$lxc_name$k/config"
                echo "lxc.network.link = lxc-bridge-nat" >> "$lxc_container_path/$lxc_name$k/config"
                echo "lxc.network.name = lxceth0" >> "$lxc_container_path/$lxc_name$k/config"
                echo "#lxc.network.hwaddr = 12:34:56:78:9A:BC" >> "$lxc_container_path/$lxc_name$k/config"
                echo "lxc.network.ipv4 = 192.168.1.$lxc_ip_address_fourth_octette" >> "$lxc_container_path/$lxc_name$k/config"
                echo "lxc.network.ipv4.gateway = $lxc_gateway" >> "$lxc_container_path/$lxc_name$k/config"
                (( lxc_ip_address_fourth_octette++ ))
            fi
        done

        clear
        echo "Append the following to /etc/network/interfaces:"
        echo ""
        echo "# Network Setting: Bridge"
        echo "auto lxc-bridge"
        echo "iface lxc-bridge inet dhcp"
        echo -e "\tbridge_ports eth0"
        echo -e "\tbridge_fd 0"
        echo -e "\tbridge_maxwait 0"

        echo ""
        echo "# Network Setting: NAT"
        echo "auto lxc-bridge-nat"
        echo "iface lxc-bridge-nat inet static"
        echo -e "\tbridge_ports none"
        echo -e "\tbridge_fd 0"
        echo -e "\tbridge_maxwait 0"
        echo -e "\taddress 193.168.1.1"
        echo -e "\tnetmask 255.255.255.0"
        echo -e "\tup iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE"

        echo ""
        echo "Uncomment the follwing in /etc/sysctl.conf:"
        echo "net.ipv4.ip_forward=1"

        echo ""
        echo "Edit $lxc_container_path/(container_name)/config to switch between bridge and NAT."

        echo ""
        exit 0
    fi
done
