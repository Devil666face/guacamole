#!/bin/bash
sudo apt install make gcc g++ libcairo2-dev libpng-dev libtool-bin libavcodec-dev libavutil-dev libswscale-dev freerdp2-dev libpango1.0-dev libssh2-1-dev libvncserver-dev libssl-dev libvorbis-dev libwebp-dev -y
sudo apt install tomcat9 tomcat9-admin tomcat9-common tomcat9-user -y
sudo systemctl start tomcat9
sudo systemctl enable tomcat9
echo "AstraMode off" >> /etc/apache2/apache2.conf
tar -xvzf guacamole-server-1.4.0.tar.gz
cd guacamole-server-1.4.0
sudo ./configure --with-init-dir=/etc/init.d
sudo make
sudo make install
sudo ldconfig
sudo systemctl enable guacd
sudo systemctl start guacd
sudo mkdir /etc/guacamole
cd ..
sudo mv guacamole-1.4.0.war /etc/guacamole/guacamole.war
sudo ln -s /etc/guacamole/guacamole.war /var/lib/tomcat9/webapps/
sudo systemctl restart tomcat9
sudo systemctl restart guacd
sudo echo "guacd-hostname: localhost" >> /etc/guacamole/guacamole.properties
sudo echo "guacd-port: 4822" >> /etc/guacamole/guacamole.properties
sudo echo "user-mapping: /etc/guacamole/user-mapping.xml" >> /etc/guacamole/guacamole.properties
sudo mkdir /etc/guacamole/{extensions,lib}
sudo sh -c "echo 'GUACAMOLE_HOME=/etc/guacamole' >> /etc/default/tomcat9"
echo "Введите логин"
read USER
echo "Введите пароль"
read PASSWORD
HASH=$(echo -n $PASSWORD | openssl md5 | sed "s/^(stdin)= //")
echo $HASH
echo "<user-mapping>
  <authorize username=\"${USER}\"
    password=\"${HASH}\"
    encoding=\"md5\">
  </authorize>
</user-mapping>" > /etc/guacamole/user-mapping.xml
sudo systemctl restart tomcat9
sudo systemctl restart guacd
echo "Подключитесь к http://your_ip:8080/guacamole логин $USER пароль $PASSWORD"
