#vnT%3K069e\N
#0R8oC)uN93snt7(H0(

mysql --host=localhost --user=myname --password=password mydb

#mysqldump -u admin --password=<pwd> <original db> | mysql -u <user name> -p <new db>
#mysqldump -u admin --password='vnT%3K069e\N' -h database-1.caolziandlh6.us-east-1.rds.amazonaws.com wp_main | mysql --password='vnT%3K069e\N' --user=admin --host=database-1.caolziandlh6.us-east-1.rds.amazonaws.com wp_dev

mysql --user=admin --password=vnT%3K069e\N --host=database-1.caolziandlh6.us-east-1.rds.amazonaws.com

mysql --password='vnT%3K069e\N' --user=admin --host=database-1.caolziandlh6.us-east-1.rds.amazonaws.com -e "CREATE DATABASE wp_dev;"
mysql --password='vnT%3K069e\N' --user=admin --host=database-1.caolziandlh6.us-east-1.rds.amazonaws.com -e "CREATE DATABASE $dbname;"

#!/bin/sh
repoName=$1
branch=$2
branch=$(echo "${branch##*/}")

if [ -z "$repoName" ]; then
  echo "\$repoName is empty"
else
  echo "\$repoName is NOT empty"
  DIR="/var/www/html/$repoName/$branch"
  if [ -d "$DIR" ]; then
    ### Take action if $DIR exists ###
    echo "Update files in ${DIR}..."
	mkdir -p $DIR
    cd $DIR
        #git pull
        runuser -u ubuntu -- git pull
  else
    ##  Control will jump here if $DIR does NOT exists ###
	mkdir -p DIR
    echo "Error: ${DIR} not found. Can not continue."
	           exit 1
  fi
fi

new_branch() {
echo "============================================"
echo "Create database & user for wordpress"
echo "============================================"
#variable database
user="wp_user"
pass="wordpress123513"
dbname="wp_db"
echo "create db name"
mysql -e "CREATE DATABASE $dbname;"
echo "Creating new user..."
mysql -e "CREATE USER '$user'@'%' IDENTIFIED BY '$pass';"
echo "User successfully created!"
echo "Granting ALL privileges on $dbname to $user!"
mysql -e "GRANT ALL PRIVILEGES ON $dbname.* TO '$user'@'%';"
mysql -e "FLUSH PRIVILEGES;"
echo "Success :)"
echo "============================================"
echo "Install WordPress menggunakan Bash Script   "
echo "============================================"
#download wordpress
curl -O https://wordpress.org/latest.tar.gz
#unzip wordpress
tar -zxvf latest.tar.gz
#Change owner & chmod
chown -R www-data:www-data wordpress/
chmod -R 755 wordpress/
#change dir to wordpress
cd wordpress
#create wp config
cp wp-config-sample.php wp-config.php
chown -R www-data:www-data wp-config.php
#set database details with perl find and replace
perl -pi -e "s/database_name_here/$dbname/g" wp-config.php
perl -pi -e "s/username_here/$user/g" wp-config.php
perl -pi -e "s/password_here/$pass/g" wp-config.php
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
mkdir wp-content/uploads
chmod 775 wp-content/uploads
#Create VirtualHost apache2 for wordpress
touch /etc/apache2/sites-available/wordpress.conf
cat > /etc/apache2/sites-available/wordpress.conf <<EOF
<VirtualHost *:80>
    ServerAdmin admin@rodpres.online
    ServerName $your_domain
    # ServerAlias
    DocumentRoot /home/oprek/wordpress
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
<Directory /home/oprek/wordpress/>
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
</Directory>
</VirtualHost>
EOF
#enable apache2
a2ensite wordpress.conf
a2enmod rewrite
a2dissite 000-default.conf
systemctl restart apache2
echo "Restart service Apache2"
systemctl restart apache2
echo "SSL generate with certbot"
apt install certbot python3-certbot-apache -y
certbot run -n --apache --agree-tos -d wp.igunawan.com -m admin@igunawan.com  --redirect
echo "========================="
echo "Installation is complete."
echo "========================="
}