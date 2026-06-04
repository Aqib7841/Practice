#!/bin/bash

ec () {
if [ $1 -eq 0 ]; then
    echo "Command Execution was successful."
else
    echo "Command failed."
    echo "Please review the step above to see what went wrong."
fi
}

ssh_config=$(sudo grep "^PermitRootLogin" /etc/ssh/sshd_config | awk '{print $2}')
max_days=$(sudo grep "^PASS_MAX_DAYS" /etc/login.defs | awk '{print $2}')
min_days=$(sudo grep "^PASS_MIN_DAYS" /etc/login.defs | awk '{print $2}')
min_pass=$(sudo grep "^minlen" /etc/security/pwquality.conf | awk -F= '{print $2}')
ufw_status=$(sudo ufw status | grep "active" | awk '{print $2}')
ww_count=$(find / -xdev -type f -perm -0002 2>/dev/null| wc -l)
empty_pass=$(sudo awk -F: '($2 == "") {print $1}' /etc/shadow)

echo "Checking Root SSH Login Status............"

if  [ "$ssh_config" == "no" ]
then
    echo "Root login over SSH is disabled. This is the recommended setting."
else
    echo "Root login over SSH is currently allowed"
    echo "It is safer to disable it."
fi

echo "======================================================================================="

echo "Checking Password Max Days Limit............"


if  [ "$max_days" -le 365 ]
then
    echo "The maximum password age is within the limit of 365 days."
else
    echo "The maximum password age is set higher than 365 days."
    echo "Consider lowering it so that passwords are rotated annually."

fi

echo "--------------------------------------------------------------------------------------"

echo "Checking Password Min Days Limit............"

if [ "$min_days" -ge 30 ]
then
    echo "The minimum password age looks fine."
else
    echo "The minimum password age is set quite low."
    echo "Keep password changing limit to 30 days minimum"
fi

echo "--------------------------------------------------------------------------------------"

echo "Checking Password Min Lenght Limit............"

if [ "$min_pass" -ge 4 ]
then
    echo "The minimum password length meets the configured requirement."
else
    echo "The minimum password length is too short."
fi

echo "======================================================================================="

echo "Checking UFW Status............"

if [ $ufw_status == active ]
then
    echo "The UFW firewall is active"
    echo "Run 'sudo ufw status' to see the full list of rules."
else
    echo "UFW firewall isn't active"
    echo "Enabling it...."
    sudo ufw enable
    ec $?
fi


echo "======================================================================================="

echo "Checking world writable files............"

if [ $ww_count -eq 0 ]
then
    echo "There are no world writable files"
else
    echo "I have found some world writable files"
    echo "These can be a security risk and should be reviewed by hand."
fi

echo "======================================================================================="

echo "Checking Suid Files............"

find / -xdev -type f -perm -4000 2>/dev/null | awk '{print}'
ec $?

echo "---------------------------------------------------------------------------------------"
    echo "The files listed above have the SUID bit set."
    echo "Check them manually"

echo "======================================================================================="

echo "Checking Empty Password Accounts.............."

if [ -z $empty_pass ]
then
    echo "There are no accounts without passwords"
else
    echo "There are accounts with empty passwords"
    echo "Please check them manually ASAP"
fi

