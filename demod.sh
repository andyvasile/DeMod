#!/bin/bash
#
# DeMod
# ----------------------------------
# description     : Script was written to help you disable security rules with ease for main domain / addon domains / subdomains
# author          : Andy Vasile <andy.vasile@hostpapa.com>
# date            : 16.03.2019
# usage           : bash <(curl -s http://andyvasile.net/s/demod.sh) <DOMAIN.TLD> <RULE-ID>
# =======

function show_help () {
        echo "DeMod v.2.1 - written by Andy Vasile <andy.vasile@hostpapa.com>"
        echo
        echo "Usage: bash <(curl -s http://andyvasile.net/s/demod.sh) -[d|e|l] <DOMAIN.TLD> <RULE-ID>"
        echo
        echo "d: Deactivate | e: Enable | l: List"
        echo
        exit 0
}

if [[ ! $# -eq 3 ]]; then
        #
        # if no parameters, will print the usage & finish the script
        #
        show_help
        echo "1"
else
        #
        # if parameter was added it will use that one
        #
        while [[ $# -gt 0 ]]
          do
            argument="$1"

              case $argument in
                -d) flag=xa; shift 1;;
                -e) flag=xd; shift 1;;
                -l) flag=xl; shift 1;;
                -*) show_help; echo "2"; break;;
                *) break;;
              esac
            done

        domain="$1"
        rule="$2"
fi
#----------------------------------
#
# This section identifies if the entered domain is addon or main domain
#
#----------------------------------
targetDomain=$(whmapi1 domainuserdata domain="$domain" | grep -i servername | cut -d: -f2 | sed 's/ //g')
#----------------------------------
#
# this section brings the ports the security rule will be disabled for:
#
#----------------------------------
servername=$(/var/cpanel/cwaf/scripts/cwaf-cli.pl -l | grep "^$targetDomain")
#----------------------------------
#
# this section will actually execute the command to disable the rule.
#
#----------------------------------
/var/cpanel/cwaf/scripts/cwaf-cli.pl -d "$servername" -$flag "$rule"
#
httpd -t
#
echo
echo "Please restart Apache if 'Syntax OK' was shown above"
#
echo "/scripts/restartsrv_httpd"
echo
