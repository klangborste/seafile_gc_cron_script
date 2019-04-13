#!/usr/bin/env bash

################################################################################
#### description: automatic seafile garbage collection script
#### ~build from reference: https://manual.seafile.com/maintain/seafile_gc.html
#### written by Max Roessler - mailmax@web.de on 13.04.2019
################################################################################

######## variable setup ########
### the script is written in such a manner that it's important to write a trailing slashs on the variable dir names
set -o nounset                              # Treat unset variables as an error
set -o errexit
sea_user="seafile"
sea_dir="/mnt/datengrab/seafile/"
web_maint_dir="/var/www/messages/"
####################

# Uncomment the following line if you rather want to run the script manually.
# Display usage if the script is not run as root user
#        if [[ $USER != "root" ]]; then
#                echo "This script must be run as root user!"
#                exit 1
#        fi
#
# echo "Super User detected!!"
# read -p "Press [ENTER] to start the procedure, this will stop the seafile server!!"
#####

#set the trigger for the maintenance page
/usr/bin/touch "${web_maint_dir}maintenance.enable" || { /bin/echo "${red}maintenance trigger could not be set${end}"; exit 1; }

# stop the server
echo Stopping the Seahub and Seafile-Server...
systemctl stop seafile.service seahub.service || { /bin/echo "${red}stop the seafile and/or seahub service failed${end}"; exit 1; }

#sleep for 10 seconds
echo Giving the server some time to shut down properly....
/bin/sleep 10 || { /bin/echo "${red}strange things happen here with a simple linux tool!${end}"; exit 1; }

# run the cleanup
echo Seafile cleanup started...
/bin/su - "${sea_user}" -s /bin/bash -c "${sea_dir}seafile-server-latest/seaf-gc.sh" || { /bin/echo "${red}update script failed!${end}"; exit 1; }

#sleep for 10 seconds
echo Giving the server some time....
/bin/sleep 5 || { /bin/echo "${red}strange things happen here with a simple linux tool!${end}"; exit 1; }

# start the server again
echo Starting the Seahub and Seafile-Server...
systemctl start seafile.service seahub.service || { /bin/echo "${red}stop the seafile and/or seahub service failed${end}"; exit 1; }

#remove the trigger for the maintenance page
/bin/rm "${web_maint_dir}maintenance.enable" || { /bin/echo "${red}maintenance trigger could not be set${end}"; exit 1; }

echo Seafile garbage collection done!

