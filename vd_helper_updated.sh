#!/bin/bash
. ./.shcss.sh

menu () {
echo "$greybgwhite Menu $end"
echo
echo "  1) Install LAMP(Apache + PHP)"
echo "  2) SSH Configure"
echo "  3) Clone a repository"
echo "  4) Set Up Apache Virtual Host"
echo "  5) Install SSL certificate"
echo "  6) Create redeploy webhook"
echo "  7) Install Composer"
echo "  8) Install Adminer"
echo "  9) Install phpMyAdmin"
echo "  10) Install MailHog"
echo "  11) Install Wordpress"
echo "  12) Install Node"
echo "  13) Create Swap"
echo "  14) Exit"
echo
echo -n "Choose one of the above options: "
}

main_menu  () {
read selection
echo
case $selection in
  1) lamp_install ; ssh_config_jump;;
  2) ssh_config ; git_clone_jump;;
  3) git_clone ; menu_return;;
  4) apache_vh_config ; menu_return;;
  5) ssl_install ; menu_return;;
  6) create_redeploy_webhook ; menu_return;;
  7) composer_install ; menu_return;;
  8) adminer_install ; menu_return;;
  9) phpMyAdmin_install ; menu_return;;
  10) mailhog_install ; menu_return;;
  11) wordpress_install ; menu_return;;
  12) node_install ; menu_return;;
  13) create_swap ; menu_return;;
  14) credits;;
  *) incorrect_selection_number ; menu_return;;
esac
}

lamp_install () {
clear
logo
#echo "please select a available PHP version"
#apt-cache showpkg php | grep -A 20 'Reverse Provides' | grep -P '^php' | colrm 7 | sort -u

PS3='please select a available PHP version: '
options=("php5.6" "php7.0" "php7.1" "php7.2" "php7.3" "php7.4" "php8.0" "php8.1" "php8.2" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "php5.6")
            php_version=5.6
            echo "you chose choice $REPLY which is $opt"
            break
            ;;
        "php7.0")
            php_version=7.0
            echo "you chose choice $REPLY which is $opt"
            break
            ;;
        "php7.1")
            php_version=7.1
            echo "you chose choice $REPLY which is $opt"
            break
            ;;
        "php7.2")
            php_version=7.2
            echo "you chose choice $REPLY which is $opt"
            break
            ;;
        "php7.3")
            php_version=7.3
            echo "you chose choice $REPLY which is $opt"
            break
            ;;
        "php7.4")
            php_version=7.4
            echo "you chose choice $REPLY which is $opt"
            break
            ;;
        "php8.0")
            php_version=8.0
            echo "you chose choice $REPLY which is $opt"
            break
            ;;
        "php8.1")
            php_version=8.1
            echo "you chose choice $REPLY which is $opt"
            break
            ;;
        "php8.2")
            php_version=8.2
            echo "you chose choice $REPLY which is $opt"
            break
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done

echo "adding PHP repository..."
sudo add-apt-repository ppa:ondrej/php -y

echo "updating..."
sudo apt-get update

echo "upgrading..."
sudo apt-get upgrade -y

echo "=================================="
echo "installing PHP $php_version + modules"
echo "=================================="
sudo apt install -y php"$php_version" libapache2-mod-php"$php_version" php"$php_version"-common php"$php_version"-mbstring php"$php_version"-gettext php"$php_version"-gd php"$php_version"-xml php"$php_version"-intl php"$php_version"-mysql php"$php_version"-mysqlnd php"$php_version"-mcrypt php"$php_version"-cli php"$php_version"-zip php"$php_version"-curl php"$php_version"-bcmath php"$php_version"-fpm
echo "=================================="
echo "installing Apache2"
echo "=================================="
#sudo add-apt-repository ppa:ondrej/apache2 -y
sudo apt install apache2
#
#NOTICE: a2enmod proxy_fcgi setenvif
#NOTICE: a2enconf php7.4-fpm

sudo systemctl stop apache2.service
sudo systemctl start apache2.service
sudo systemctl enable apache2.service

echo "your PHP Ver is :"
php -v
echo
}

menu_return (){
while true; do
    read -p "Would you like to go back to the main menu? [y/n] "  input
    case $input in
        [yY]*)
            clear
            logo
            menu
            main_menu
            break
            ;;
        [nN]*)
            credits
            exit 1
            ;;
         *)
            echo
            incorrect_selection_letter
            echo
            main_menu
    esac
done
}

ssh_config_jump (){
while true; do
    read -p "Would you like to set an SSH key? [y/n] "  input
    case $input in
        [yY]*)
            clear
            logo
            ssh_config
            break
            ;;
        [nN]*)
            clear
            logo
            menu
            main_menu
            exit 1
            ;;
         *)
            echo
            incorrect_selection_letter
            echo
            main_menu
    esac
done
}

ssh_config () {
clear
logo
echo "$greybgwhite SSH Key Configuration $white"
echo
echo "$grey Generating SSH Key... $end"
echo
sleep 1
yes "" | ssh-keygen -t rsa
sleep 1
echo
echo
echo "$green2  Copy generated Public Key from your newly created Private Key. $end"
sleep 2
echo "$green2 Open https://github.com/settings/ssh/new  alongside with the web browser in the GitHub SSH Key Creation and add copied key $end"
sleep 1
echo
echo Starting in a 3 seconds...
sleep 3
echo
echo "$green Press [ENTER] to continue ONLY after you've done setting up your SSH key: $end"
sleep 3
#chmod 600 ~/.ssh/id_rsa
#cd ~/.ssh/
ssh-keygen -y -f ~/.ssh/id_rsa
read -p "Press enter to continue"
read -p enter_continue;
echo "$grey Setting up host authenticator...$end"
sleep 1
echo
ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
echo
echo "$grey Authenticating...$end"
echo "$negative"
ssh -T git@github.com
echo "$end"
git_clone_jump
}

git_clone_jump (){
while true; do
    read -p "Would you like to clone a repository? [y/n] "  input
    case $input in
        [yY]*)
            clear
            logo
            git_clone
            break
            ;;
        [nN]*)
            clear
            logo
            menu
            main_menu
            exit 1
            ;;
         *)
            echo
            incorrect_selection_letter
            echo
            main_menu
    esac
done
}

git_clone () {
cd /var/www/html/

#//TODO check permissions
#sudo chmod -R 777 /var/www/html
sudo chown -R www-data:ubuntu /var/www/html
sudo chmod -R 775 /var/www/html
sudo usermod -a -G www-data ubuntu

clear
logo
echo "$greybgwhite Advanced GitHub Cloner $end"
echo
echo "$grey For reference: https://github.com/USERNAME/REPOSITORY $end"
echo
while true; do
echo "$purple2 Enter the username that owns the repository: $end"
echo
read username
echo
echo "$purple2 Enter the repository name: $end"
echo
read repo
echo
echo "$cyan If the repository is succesfully created, it will be saved in: `pwd`  $end"
echo
git clone git@github.com:$username/$repo.git
git_cloner_loop
done
}

git_cloner_loop () {
echo
while true; do
    read -p "Would you like to go clone another repository? [y/n] "  input
    case $input in
        [yY]*)
            git_clone
            break
            ;;
        [nN]*)
            clear
            logo
            menu
            main_menu
            exit 1
            ;;
         *)
            echo
            incorrect_selection_letter
            main_menu
    esac
done
}

apache_vh_config () {
clear
logo
echo "=================================="
echo "Create virtual host apache"
echo "=================================="

#sudo nano /etc/apache2/sites-available/000-default.conf

echo "Enter the ServerName you want"
read -p "e.g. mydomain.tld (without www) : " servn
echo "Enter a ServerAlias"
read -p "e.g. www or dev for dev.website.com : " cname
echo "Enter the path of DocumentRoot"
read -p "e.g. /var/www/, dont forget the / : " dir
#echo "Enter the listened IP for the web server"
#read -p "e.g. * : " listen
#echo "Enter the port on which the web server should respond"
#read -p "e.g. 80 : " port

#mkdir /var/log/apache2/$cname_$servn
alias=$cname.$servn
if [[ "${cname}" == "" ]]; then
alias=$servn
fi

echo "#### $cname $servn
<VirtualHost *:80>
ServerName $servn
ServerAlias $alias
DocumentRoot $dir
<Directory $dir>
Options -Indexes +FollowSymLinks
        AllowOverride All
Order allow,deny
Allow from all
Require all granted
</Directory>
ErrorLog '$'{APACHE_LOG_DIR}/$cname.$servn-error.log
    CustomLog '$'{APACHE_LOG_DIR}/$cname.$servn-access.log combined
</VirtualHost>" | sudo tee -a /etc/apache2/sites-available/$cname.$servn.conf > /dev/null
if echo -f "/etc/apache2/sites-available/$cname.$servn.conf"; then
echo "Virtual host /etc/apache2/sites-available/$cname.$servn.conf created !"
else
echo "Virtual host /etc/apache2/sites-available/$cname.$servn.conf wasn't created !"
fi

#echo "Would you like me to create ssl virtual host [y/n]? "
#read q
#if [[ "${q}" == "yes" ]] || [[ "${q}" == "y" ]]; then
#openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/certs/$cname.$servn.key -out /etc/ssl/certs/$cname.$servn.crt
#if [ -e "/etc/ssl/certs/$cname.$servn.key" ]; then
#echo "Certificate key created !"
#else
#echo "Certificate key wasn't created !"
#fi
#if [ -e "/etc/ssl/certs/$cname.$servn.crt" ]; then
#echo "Certificate created !"
#else
#echo "Certificate wasn't created !"
#fi
#
#echo "#### ssl $cname $servn
#<VirtualHost $listen:443>
#SSLEngine on
#SSLCertificateFile /etc/ssl/certs/$cname.$servn.crt
#SSLCertificateKeyFile /etc/ssl/certs/$cname.$servn.key
#ServerName $alias
#ServerAlias $alias
#DocumentRoot $dir$cname/html/
#<Directory $dir$cname>
#Options Indexes FollowSymLinks MultiViews
#AllowOverride All
#Order allow,deny
#Allow from all
#Satisfy Any
#</Directory>
#</VirtualHost>" > /etc/apache2/sites-enabled/ssl.$cname.$servn.conf
#if ! echo -e /etc/apache2/sites-enabled/ssl.$cname.$servn.conf; then
#echo "SSL Virtual host wasn't created !"
#else
#echo "SSL Virtual host created !"
#fi
#fi

sudo a2ensite "$cname.$servn"
#sudo ln -s /etc/apache2/sites-available/domain1.com.conf /etc/apache2/sites-enabled/
echo "Testing configuration"
sudo apachectl configtest
echo "Would you like me to restart the server [y/n]? "
read q
if [[ "${q}" == "yes" ]] || [[ "${q}" == "y" ]]; then
sudo apache2ctl -k graceful
sudo systemctl reload apache2
fi

echo " "
echo "----------------------------"
echo "You have successfully created the domain : http://$cname.$servn"
echo "Virtual host root folder : $docroot"
#echo "Error & access logs folder (doc folder) : /var/log/$cname_$servn"
echo "----------------------------"
}

ssl_install () {
clear
logo
echo "=================================="
echo "Install SSL certificate"
echo "=================================="
echo "Ensure that your version of snapd is up to date"
sudo snap install core; sudo snap refresh core
echo "Remove certbot-auto and any Certbot OS packages"
sudo apt-get remove certbot
echo "Install Certbot"
sudo snap install --classic certbot
echo "Prepare the Certbot command"
sudo ln -s /snap/bin/certbot /usr/bin/certbot
echo "Choose how you'd like to run Certbot"
sudo certbot --apache
echo "Test automatic renewal"
sudo certbot renew --dry-run
echo "To confirm that your site is set up properly, visit https://yourwebsite.com/ in your browser and look for the lock icon in the URL bar."
#done
}

wordpress_install () {
clear
logo
echo "=================================="
echo "Install WordPress"
echo "=================================="

echo "Enter the folder name you want"
read -p "e.g. mydomain : " dirn
echo "Enter the ServerName you want"
read -p "e.g. mydomain.tld (without www) : " servn
echo "Db name"
read -p ": " dbname
echo "Db username"
read -p ": " dbuser
echo "Db password"
read -p ": " dbpass
#change permissions
#sudo chown -R www-data:ubuntu /var/www/html
#sudo chmod -R 775 /var/www/html
#sudo usermod -a -G www-data ubuntu

cd /var/www/html
#download wordpress
sudo curl -O https://wordpress.org/latest.tar.gz
#unzip wordpress
sudo tar -zxvf latest.tar.gz
#remove wp file
sudo rm /var/www/html/latest.tar.gz
# Rename wordpress directory to dirn
sudo mv wordpress $dirn
#Change owner & chmod
sudo chown -R www-data:www-data $dirn/
sudo chmod -R 755 $dirn/
# Change directory to dirn
cd $dirn
#create wp config
sudo cp wp-config-sample.php wp-config.php
#sudo chown -R www-data:www-data wp-config.php
#set database details with perl find and replace
perl -pi -e "s/database_name_here/$dbname/g" wp-config.php
perl -pi -e "s/username_here/$dbuser/g" wp-config.php
perl -pi -e "s/password_here/$dbpass/g" wp-config.php
#set WP salts
perl -i -pe'
  BEGIN {
    @chars = ("a" .. "z", "A" .. "Z", 0 .. 9);
    push @chars, split //, "!@#$%^&*()-_ []{}<>~\`+=,.;:/?|";
    sub salt { join "", map $chars[ rand @chars ], 1 .. 64 }
  }
  s/put your unique phrase here/salt()/ge
' wp-config.php
#create uploads folder and set permissions
sudo mkdir wp-content/uploads
sudo chmod 775 wp-content/uploads

##Create VirtualHost apache2 for wordpress
#touch /etc/apache2/sites-available/$servn.conf
#cat > /etc/apache2/sites-available/$servn.conf <<EOF
#<VirtualHost *:80>
#    ServerName $your_domain
#    # ServerAlias
#    DocumentRoot /var/www/html/$dirn
#    ErrorLog ${APACHE_LOG_DIR}/error.log
#    CustomLog ${APACHE_LOG_DIR}/access.log combined
#<Directory /var/www/html/$dirn/>
#        Options Indexes FollowSymLinks
#        AllowOverride None
#        Require all granted
#</Directory>
#</VirtualHost>
#EOF
##enable apache2
#a2ensite $servn.conf
#a2enmod rewrite
#a2dissite 000-default.conf
#echo "Restart service Apache2"
#systemctl restart apache2
#echo "SSL generate with certbot"
#apt install certbot python3-certbot-apache -y
#certbot run -n --apache --agree-tos -d wp.igunawan.com -m admin@igunawan.com  --redirect
}

node_install () {
clear
logo
echo "=================================="
echo "Install Node js"
echo "=================================="


}

create_swap () {
clear
logo
echo "=================================="
echo "Create Swap"
echo "=================================="
echo "see if the system has any configured swap"
sudo swapon --show
echo "verify that there is no active swap"
free -h
echo "Checking Available Space on the Hard Drive Partition"
df -h
echo "Enter swap size you want"
read -p "e.q. 2G : " swap_size
read -p "Enter swap path (default /swapfile if blank): " swap_path
swap_path=${swap_path:-'/swapfile'}
sudo fallocate -l $swap_size $swap_path

ls -lh /swapfile
#Make the file only accessible to root
sudo chmod 600 $swap_path
#Verify the permissions change
ls -lh $swap_path
#mark the file as swap space
sudo mkswap $swap_path
#After marking the file, we can enable the swap file, allowing our system to start using it
sudo swapon $swap_path
#Verify that the swap is available
sudo swapon --show

#Back up the /etc/fstab file in case anything goes wrong:
sudo cp /etc/fstab /etc/fstab.bak
#Add the swap file information to the end of your /etc/fstab file
echo "/$swap_path none swap sw 0 0" | sudo tee -a /etc/fstab
echo
echo "Done! You now have a $swap_size swap file at $swap_path"
}

create_redeploy_webhook () {
clear
logo
echo "=================================="
echo "Create redeploy webhook"
echo "=================================="
sudo apt-get update
sudo apt-get -y install webhook
sudo mkdir /var/www/webhooks
sudo touch /var/www/webhooks/hooks.json

read -p "Enter secret with witch you want webhook will be recognized (default 42 if blank): " secret_token
secret_token=${secret_token:-42}

json_data=$(cat <<EOF
[
  {
    "id": "redeploy-webhook",
    "execute-command": "/var/www/webhooks/commands/simple-pull.sh",
    "response-message": "Executing redeploy webhook...",
     "include-command-output-in-response": true,
     "pass-arguments-to-command":
        [
          {
            "source": "payload",
            "name": "repository.name"
          }
        ],
    "trigger-rule": {
      "match":
      {
        "type": "value",
        "value": $secret_token,
        "parameter":
        {
          "source": "url",
          "name": "token"
        }
      }
    }
  }
]
EOF
)

echo "$json_data" | sudo tee /var/www/webhooks/hooks.json

sudo mkdir /var/www/webhooks/commands
sudo touch /var/www/webhooks/commands/simple-pull.sh
sudo chmod 0755 /var/www/webhooks/commands/simple-pull.sh

echo "$purple2 Enter absolute path to yor repository : $end"
echo
read repository_path
echo "$json_data" | sudo tee /var/www/webhooks/hooks.json
printf "#!/bin/sh\n
        cd %s\n
        git pull\n" "$repository_path" | sudo tee /var/www/webhooks/commands/simple-pull.sh > /dev/null

#        !/bin/sh
#        repoName=$1
#        if [ -z "$repoName" ]; then
#          echo "\$repoName is empty"
#        else
#          echo "\$repoName is NOT empty"
#          DIR="/var/www/html/$repoName"
#          if [ -d "$DIR" ]; then
#            ### Take action if $DIR exists ###
#            echo "Update files in ${DIR}..."
#            cd $DIR
#                git pull
#                runuser -u ubuntu -- git pull
#          else
#            ##  Control will jump here if $DIR does NOT exists ###
#            echo "Error: ${DIR} not found. Can not continue."
#           exit 1
#          fi
#        fi

echo "$purple2 Enter webhook ip address (in AWS it will be Private IPv4 addresses): $end"
echo
read webhook_ip

echo "$purple2 $webhook_ip:9000/hooks/redeploy-webhook - won’t work $end"
echo "$purple2 $webhook_ip:9000/hooks/redeploy-webhook?token=$secret_token - will work $end"

echo "$purple2 Dont forget to open 9000 port in AWS security group!!! $end"
#kill all on 9000 port
#sudo kill -9 `sudo lsof -t -i:9000`
sudo -b webhook -hooks /var/www/webhooks/hooks.json /dev/null 2>&1 &
#sudo -b webhook -hooks /var/www/webhooks/hooks.json -verbose
#sudo -b webhook -hooks /var/www/webhooks/hooks.json -ip="$webhook_ip" /dev/null 2>&1 &
#done
}

mailhog_install () {
clear
logo
echo "=================================="
echo "Install MailHog"
echo "=================================="
sudo apt-get -y install golang-go
go get github.com/mailhog/MailHog

#~/go/bin/MailHog -api-bind-addr "104.248.143.26:1029" -ui-bind-addr "104.248.143.26:1029" -smtp-bind-addr "104.248.143.26:1030"
#sudo -b ~/go/bin/MailHog -api-bind-addr "207.154.196.194:1029" -ui-bind-addr "207.154.196.194:1029" -smtp-bind-addr "207.154.196.194:1030" /dev/null 2>&1 &

#sudo ufw allow 1029
#sudo ufw allow 1030
#sudo ufw status verbose
#done
}

composer_install () {
clear
logo
echo "=================================="
echo "Install Composer"
echo "=================================="
sudo curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
composer -vvv about
#done
}

adminer_install () {
clear
logo
echo "=================================="
echo "Install adminer"
echo "=================================="

#apt install
#sudo apt install adminer
#sudo a2enconf adminer
#sudo systemctl reload apache2
#echo "To confirm that adminer set up properly, visit https://yourwebsite.com/adminer"

#curl download
echo "$purple2 Enter absolute path where you want to install adminer : $end"
echo
read adminer_path
echo
cd $adminer_path
echo
read -p "Enter filename with witch you want adminer will be recognized (default vd_adminer if blank): " adminer_filename
adminer_filename=${adminer_filename:-vd_adminer}
sudo curl -L -o "$adminer_filename".php  https://github.com/vrana/adminer/releases/download/v4.7.8/adminer-4.7.8.php
echo "To confirm that adminer set up properly, visit https://yourwebsite.com/$adminer_filename.php"
#done
}

phpMyAdmin_install () {
clear
logo
echo "=================================="
echo "Install and Secure phpMyAdmin"
echo "=================================="
sudo apt-get install -y phpmyadmin
sudo service apache2 restart
#done
}

incorrect_selection_number() {
  echo -n "$red  Incorrect selection, try again: $end"
  main_menu
  echo
}

incorrect_selection_letter() {
  echo -n "$red Incorrect selection, try again: $end"
  while true; do
    read -p ""  input
    case $input in
        [yY]*)
            clear
            logo
            menu
            main_menu
            break
            ;;
        [nN]*)
            clear
            credits
            exit 1
            ;;
         *)
            echo
            incorrect_selection_letter
            main_menu
    esac
done
  echo
}

logo () {
echo """$cyan
██╗   ██╗██╗ █████╗ ██████╗ ██╗   ██╗ ██████╗████████╗
██║   ██║██║██╔══██╗██╔══██╗██║   ██║██╔════╝╚══██╔══╝
██║   ██║██║███████║██║  ██║██║   ██║██║        ██║
╚██╗ ██╔╝██║██╔══██║██║  ██║██║   ██║██║        ██║
 ╚████╔╝ ██║██║  ██║██████╔╝╚██████╔╝╚██████╗   ██║
██╗══██╗███████╗██╗╝╚═══██╗  ╚══██████╗═███████╗██████╗
██║  ██║██╔════╝██║     ██║     ██╔══██╗██╔════╝██╔══██╗
███████║█████╗  ██║     ██║     ██████╔╝█████╗  ██████╔╝
██╔══██║██╔══╝  ██║     ██║     ██╔═══╝ ██╔══╝  ██╔══██╗
██║  ██║███████╗███████╗███████╗██║     ███████╗██║  ██║
╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝     ╚══════╝╚═╝  ╚═╝
$end"""
}

loader () {
clear
echo
credits
sleep 1
echo Starting..
sleep 2
clear
}

credits () {
clear
echo
echo Script created by: Viaduct Co
echo https://viaduct.pro/
echo
}

# Script Start

clear
loader
logo
menu
main_menu
