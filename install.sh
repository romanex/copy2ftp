#!/bin/sh

export $(xargs < ./env)

# Script vars
LOGFILE='/var/log/send2rozetka.log'
SCRIPTFOLDER='/opt/send2ftp'
TIMESTAMP='date "+%Y-%m-%d %H:%M:%S"'
SCRIPTFILE='/opt/send2ftp/copy2ftp.sh'
SCHEDULER='30 10 * * *'
#* * * * * "command to be executed"
#- - - - -
#| | | | |
#| | | | ----- Day of week (0 - 7) (Sunday=0 or 7)
#| | | ------- Month (1 - 12)
#| | --------- Day of month (1 - 31)
#| ----------- Hour (0 - 23)
#------------- Minute (0 - 59)

# Credentials
FTPHOST=$MYHOST
FTPUSER=$MYUSER
FTPPASSWD=$MYPASSWD

# User vars
SOURCEFOLDER='/folder/obmen/'
FTPFOLDER='public_html'
FILE='rozetka.xml'

# Creating script folder
echo "Creating script folder..."
if [ ! -d "$SCRIPTFOLDER" ]; then
    mkdir $SCRIPTFOLDER
fi

# Creating LOG file
echo "Creating LOG file..."
if [ ! -f "$LOGFILE" ]; then
    touch $LOGFILE
fi

# Creating script file
echo "Creating script file..."
if [ ! -f "$SCRIPTFILE" ]; then
cat > $SCRIPTFILE << EOF
#!/bin/sh
TIMESTAMP=\`date "+%Y-%m-%d %H:%M:%S"\`
LOGFILE='/var/log/send2rozetka.log'
cd $SOURCEFOLDER

if [ -f "$SOURCEFOLDER$FILE" ]; then
echo "\$TIMESTAMP File $FILE uploading...." >> $LOGFILE
ftp -n $FTPHOST <<END_SCRIPT
quote USER $FTPUSER
quote PASS $FTPPASSWD
binary
cd $FTPFOLDER
put $FILE
quit
END_SCRIPT
echo "\$TIMESTAMP File $FILE uploaded" >> $LOGFILE
exit 0
else
echo "\$TIMESTAMP File $FILE doesn't exist" >> \$LOGFILE
fi
EOF
chmod +x $SCRIPTFILE
fi


# Add cron job...
echo "Creating cron job..."
#write out current crontab
crontab -l > tmpcron
#echo new cron into cron file
echo "$SCHEDULER root $SCRIPTFILE" >> tmpcron
#install new cron file
crontab tmpcron
rm tmpcron
