  cd ~/valeo_project/buildroot                                       
# On efface les traces de l'échec précédent  
make aesd-assignments-dirclean                                                                                 

# On relance (Buildroot va re-télécharger votre code corrigé)
make -j$(nproc)
file output/target/usr/bin/valeo_ivc_socket
ls output/target/usr/bin/valeo_ivc_socket
cd valeo_project/
ls output/target/usr/bin/valeo_ivc_socket
ls
./build.sh
cd buildroot/
make menuconfig
make menuconfig

cd ..
./build.sh

cd buildroot/
make aesd-assignments-dirclean 

# On relance (Buildroot va re-télécharger votre code corrigé)

make -j$(nproc) 

export PATH=$(echo $PATH | tr ':' '\n' | grep -v ' ' | tr '\n' ':' | sed 's/:$//') 

make -j$(nproc) 
gedit /etc/wsl.conf


##
echo "diesntag" | nc localhost 9000 

tail -f /var/log/syslog

tail -f /var/log/syslog | grep aesdsocket

tail /var/log/syslog