#!/bin/bash
#
# https://github.com/KnallbertLp/docker-homelab
#

if [[ "$EUID" -ne 0 ]]; then
	echo "Sorry, you need to run this as root"
	exit
fi

SOURCE='${BASH_SOURCE[0]}'
while [ -h '$SOURCE' ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR='$( cd -P '$( dirname '$SOURCE' )' >/dev/null 2>&1 && pwd )'
  SOURCE='$(readlink '$SOURCE')'
  [[ $SOURCE != /* ]] && SOURCE='$DIR/$SOURCE' # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR='$( cd -P '$( dirname '$SOURCE' )' >/dev/null 2>&1 && pwd )'

sudo touch /etc/cloud/cloud-init.disabled
sudo echo 'network: {config: disabled}' > /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg

sudo dpkg-reconfigure tzdata

sudo apt update -y
sudo apt upgrade -y
sudo apt autoremove -y

sudo dpkg-reconfigure keyboard-configuration
sudo setupcon -f
sudo service keyboard-setup restart

sudo echo 'Keyboard setup done!'

sudo echo '# This file is generated from information provided by the datasource.  Changes
# to it will not persist across an instance reboot.  To disable cloud-init'\''s
# network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
# >> /etc/netplan/50-cloud-init.yaml
# Oh, wait, we already did that, never mind!

network:
    version: 2
    ethernets:
        eth0:
            dhcp4: true
            dhcp6: true
            optional: true
    wifis:
        wlan0:
            dhcp4: true
            dhcp6: true
            optional: true
            access-points:
                "Unknown_nomap":
                    password: "3440KnallbertHotspotLogin4330"
' > /etc/netplan/50-cloud-init.yaml
sudo netplan generate
sudo netplan apply

sudo echo 'Wifi setup done!'
read -p 'Press any key to resume...'

sudo echo 'Setting up ufw ... '
sudo apt update -y
sudo apt full-upgrade -y
sudo apt autoremove -y

sudo apt install ufw -y
sudo ufw logging off 
sudo ufw allow ssh
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable

sudo echo 'Setting up avahi network discovery ...'
sudo apt install avahi-daemon -y
sudo systemctl start avahi-daemon
sudo systemctl enable avahi-daemon
sudo ufw allow 5353/udp

sudo echo 'What should the name of the server be?'
read setname
sudo hostnamectl set-hostname "$setname"
sudo systemctl restart avahi-daemon

sudo echo 'Setting up unattended-upgrades ...'
sudo apt update -y
sudo apt full-upgrade -y
sudo apt autoremove -y

sudo apt install unattended-upgrades -y
sudo echo '// Automatically upgrade packages from these (origin:archive) pairs
//
// Note that in Ubuntu security updates may pull in new dependencies
// from non-security sources (e.g. chromium). By allowing the release
// pocket these get automatically pulled in.
Unattended-Upgrade::Allowed-Origins {
        "${distro_id}:${distro_codename}";
        "${distro_id}:${distro_codename}-security";
        // Extended Security Maintenance; doesn'"'"'t necessarily exist for
        // every release and this system may not have it installed, but if
        // available, the policy for updates is such that unattended-upgrades
        // should also install from here by default.
        //"${distro_id}ESMApps:${distro_codename}-apps-security";
        //"${distro_id}ESM:${distro_codename}-infra-security";
        "${distro_id}:${distro_codename}-updates";
        "${distro_id}:${distro_codename}-proposed";
        "${distro_id}:${distro_codename}-backports";
        "Docker:${distro_codename}";

};

// Python regular expressions, matching packages to exclude from upgrading
Unattended-Upgrade::Package-Blacklist {
    // The following matches all packages starting with linux-
//  "linux-";

    // Use $ to explicitely define the end of a package name. Without
    // the $, "libc6" would match all of them.
//  "libc6$";
//  "libc6-dev$";
//  "libc6-i686$";

    // Special characters need escaping
//  "libstdc\\+\\+6$";

    // The following matches packages like xen-system-amd64, xen-utils-4.1,
    // xenstore-utils and libxenstore3.0
//  "(lib)?xen(store)?";

    // For more information about Python regular expressions, see
    // https://docs.python.org/3/howto/regex.html
};

// This option controls whether the development release of Ubuntu will be
// upgraded automatically. Valid values are "true", "false", and "auto".
Unattended-Upgrade::DevRelease "auto";

// This option allows you to control if on a unclean dpkg exit
// unattended-upgrades will automatically run
//   dpkg --force-confold --configure -a
// The default is true, to ensure updates keep getting installed
Unattended-Upgrade::AutoFixInterruptedDpkg "true";

// Split the upgrade into the smallest possible chunks so that
// they can be interrupted with SIGTERM. This makes the upgrade
// a bit slower but it has the benefit that shutdown while a upgrade
// is running is possible (with a small delay)
Unattended-Upgrade::MinimalSteps "true";

// Install all updates when the machine is shutting down
// instead of doing it in the background while the machine is running.
// This will (obviously) make shutdown slower.
// Unattended-upgrades increases logind'"'"'s InhibitDelayMaxSec to 30s.
// This allows more time for unattended-upgrades to shut down gracefully
// or even install a few packages in InstallOnShutdown mode, but is still a
// big step back from the 30 minutes allowed for InstallOnShutdown previously.
// Users enabling InstallOnShutdown mode are advised to increase
// InhibitDelayMaxSec even further, possibly to 30 minutes.
Unattended-Upgrade::InstallOnShutdown "false";

// Send email to this address for problems or packages upgrades
// If empty or unset then no email is sent, make sure that you
// have a working mail setup on your system. A package that provides
// '"'"'mailx'"'"' must be installed. E.g. "user@example.com"
//Unattended-Upgrade::Mail "";

// Set this value to one of:
//    "always", "only-on-error" or "on-change"
// If this is not set, then any legacy MailOnlyOnError (boolean) value
// is used to chose between "only-on-error" and "on-change"
//Unattended-Upgrade::MailReport "on-change";

// Remove unused automatically installed kernel-related packages
// (kernel images, kernel headers and kernel version locked tools).
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";

// Do automatic removal of newly unused dependencies after the upgrade
Unattended-Upgrade::Remove-New-Unused-Dependencies "true";

// Do automatic removal of unused packages after the upgrade
// (equivalent to apt-get autoremove)
Unattended-Upgrade::Remove-Unused-Dependencies "true";

// Automatically reboot *WITHOUT CONFIRMATION* if
//  the file /var/run/reboot-required is found after the upgrade
Unattended-Upgrade::Automatic-Reboot "true";

// Automatically reboot even if there are users currently logged in
// when Unattended-Upgrade::Automatic-Reboot is set to true
Unattended-Upgrade::Automatic-Reboot-WithUsers "true";

// If automatic reboot is enabled and needed, reboot at the specific
// time instead of immediately
//  Default: "now"
Unattended-Upgrade::Automatic-Reboot-Time "now";

// Use apt bandwidth limit feature, this example limits the download
// speed to 70kb/sec
//Acquire::http::Dl-Limit "70";

// Enable logging to syslog. Default is False
Unattended-Upgrade::SyslogEnable "true";

// Specify syslog facility. Default is daemon
Unattended-Upgrade::SyslogFacility "daemon";

// Download and install upgrades only on AC power
// (i.e. skip or gracefully stop updates on battery)
Unattended-Upgrade::OnlyOnACPower "false";

// Download and install upgrades only on non-metered connection
// (i.e. skip or gracefully stop updates on a metered connection)
Unattended-Upgrade::Skip-Updates-On-Metered-Connections "false";

// Verbose logging
Unattended-Upgrade::Verbose "true";

// Print debugging information both in unattended-upgrades and
// in unattended-upgrade-shutdown
Unattended-Upgrade::Debug "false";

// Allow package downgrade if Pin-Priority exceeds 1000
Unattended-Upgrade::Allow-downgrade "false";
' > /etc/apt/apt.conf.d/50unattended-upgrades

sudo echo 'APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "1";
APT::Periodic::Unattended-Upgrade "1";
' > /etc/apt/apt.conf.d/20auto-upgrades

sudo echo 'Setting up docker... '
sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=arm64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update -y
sudo apt install docker-ce docker-ce-cli containerd.io -y

sudo echo 'Setting up utilities for docker... '
sudo apt update
sudo apt install cron -y
sudo systemctl enable cron

sudo apt install docker-compose wget sed grep coreutils -y


function mount_device {
# $1 is the question, e.g. 'Which device do you want to use as storage for Nextcloud?: '
# $2 is the standard mounting location, e.g. 'LABEL="nextcloud"' https://wiki.ubuntuusers.de/Labels/#Dateisystem-Label
# $3 is the mounting options without the mounting location , e.g. '/home/nextcloud/storage ext4    defaults,nofail 0       2'
declare -a blkids
readarray -t blkids <<< "$(sudo blkid)"
PS3="$1"
autoexists=false
chcksnmbr='^[0-9]+$'

for foo in "${blkids[@]}"; do
   if [[ $foo == *$2* ]]; then
      echo "Automatic preselection possible!"
      echo "  >> $foo <<  "
      echo "This will be choice number (1)"
      echo
      blkids=("  >> ${foo} <<  " "${blkids[@]}")
      break;
    fi
done

select item in "${blkids[@]}";
do
  if ! [[ $REPLY =~ $chcksnmbr ]] ; then
   echo "Enter one of the available numbers"
   mount_device "$1" "$2" "$3"
  else
    if [ "$REPLY" -gt 0 ] && [ "$REPLY" -le ${#blkids[@]} ] ; then
      REPLY=$((REPLY-1))
      echo "[$((REPLY+1))] > ${blkids[${REPLY}]}"
      if [[ ${blkids[${REPLY}]} == *$2* ]]; then
         echo "$(echo "$2" | tr -d '"')"  "$3" | sudo tee -a /etc/fstab > /dev/null
      elif [[ ${blkids[${REPLY}]} == *UUID=* ]]; then
         UUID=$(echo "${blkids[${REPLY}]}" | grep  -oE '\sUUID="[[:alnum:][:punct:]]+"\s'| tr -d '"' | sed 's/ *$//g')
         echo "${UUID:1}  $3" | sudo tee -a /etc/fstab > /dev/null
       fi
    else
      echo 'Enter one of the available numbers'
      mount_device "$1" "$2" "$3"
    fi
  fi
  break;
done
}

sudo echo 'Setting up nextcloud docker container... '
sudo adduser nextcloud --disabled-login --gecos "" --ingroup docker
sudo runuser -l nextcloud -c 'mkdir -p /home/nextcloud/storage'
mount_device 'Which device do you want to use as storage for Nextcloud?: ' 'LABEL="nextcloud"' '/home/nextcloud/storage ext4    defaults,nofail 0       2'
sudo runuser -l nextcloud -c 'wget -P /home/nextcloud/ https://raw.githubusercontent.com/KnallbertLp/docker-homelab/master/nextcloud/docker-compose.yaml'
sudo runuser -l nextcloud -c 'mkdir -p /home/nextcloud/storage/secrets'

sudo apt install openssl -y
openssl rand -base64 32 > /home/nextcloud/storage/secrets/mysql_root_password
openssl rand -base64 32 > /home/nextcloud/storage/secrets/mysql_user_password

sudo runuser -l nextcloud -c 'sed -i "s~MYSQL_PASSWORD:[a-zA-Z0-9[:space:]]*~MYSQL_PASSWORD: $(cat /dev/urandom | tr -dc '"'"'a-zA-Z0-9'"'"' | fold -w $((( $(( $RANDOM % 64 )) + 100 ))) | head -n 1)~g" docker-compose.yaml'
sudo runuser -l nextcloud -c 'sed -i "s~REDISPASSWORD~$(cat /dev/urandom | tr -dc '"'"'a-zA-Z0-9'"'"' | fold -w $((( $(( $RANDOM % 64 )) + 100 ))) | head -n 1)~g" docker-compose.yaml'

sudo crontab -u nextcloud -l > mycron; echo '@reboot cd /home/nextcloud && docker-compose pull --include-deps && docker-compose up -d && docker image prune -f' >> mycron && echo '0 * * * * cd /home/nextcloud && docker-compose pull --include-deps && docker-compose up -d && docker image prune -f' >> mycron && echo '*/5 * * * * docker exec -d -u www-data nextcloud-app php -f /var/www/html/cron.php' >> mycron && echo '*/10 * * * *  docker exec -d -u www-data nextcloud-app ./occ preview:pre-generate' >> mycron && crontab -u nextcloud mycron && rm -rf mycron
sudo ufw allow 80

sudo ufw reload 

#sudo apt install openvpn -y
