#!/bin/bash

# Author: Alvosec
# Website: https://alvosec.com
# Email: info@alvosec.com

echo "  __   __    _  _   __   ____  ____  ___ "
echo " / _\ (  )  / )( \ /  \ / ___)(  __)/ __)"
echo "/    \/ (_/\\ \/ /(  O )\___ \ ) _)( (__ "
echo "\_/\_/\____/ \__/  \__/ (____/(____)\___)"
echo ""

# List commands
commands=(
  "Scan DNS ports 53, 443, 853"
  "DNS TTL"
  "DIG SOA"
  "DIG ANY"
  "Open resolver"
  "DNS update"
  "Check for predictable-port recursion vulnerability"
  "Check DNS best practice"
  "Check predictable-TXID"
  "DNS cache snooping"
  "DNSSEC check"
  "DNS zone transfer"
  "Check if DoH works"
)

echo "Choose a command from the list below:"
for i in "${!commands[@]}"; do
  echo "[+] $i  : ${commands[$i]}"
done

read -p "Enter the number of the command you want to run: " cmd_num

read -p "Enter the DNS server to run the command on: " dns_server

case $cmd_num in
  0) sudo nmap -p 853,443,53 $dns_server ;;
  1) dig ttl @$dns_server example.com ;;
  2) dig soa @$dns_server example.com ;;
  3) dig any @$dns_server example.com ;;
  4) sudo nmap -sU -p 53 --script=dns-recursion $dns_server ;;
  5) sudo nmap -sU -p 53 --script=dns-update --script-args=dns-update.hostname=example.com,dns-update.ip=192.0.2.1 $dns_server ;;
  6) sudo nmap -sU -p 53 --script=dns-random-srcport $dns_server ;;
  7) nmap -sn -Pn $dns_server --script dns-check-zone --script-args='dns-check-zone.domain=example.com' ;;
  8) sudo nmap -sU -p 53 --script=dns-random-txid $dns_server ;;
  9) read -p "Enter a comma-separated list of domains to snoop on (e.g. host1,host2,host3): " domains
     sudo nmap -sU -p 53 --script dns-cache-snoop.nse --script-args "dns-cache-snoop.mode=timed,dns-cache-snoop.domains={$domains}" $dns_server ;;
  10) dig @$dns_server example.com +dnssec +cd ;;
  11) dig AXFR example.com @$dns_server ;;
  12) curl -I --doh https://$dns_server/dns-query https://www.google.com ;;
  
  *) echo "Invalid command number. Exiting." ;;
esac

# dig @dns.alvosec.com example.com A +norecurse #if servfail means it's not in cache
