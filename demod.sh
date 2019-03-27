#!/bin/bash

function show_help () {
        # This function simply shows the script usage.
        #
        echo "DeMod v.2.1 - written by Andy Vasile <andy.vasile@hostpapa.com>"
        echo
        echo "Usage: bash <(curl -s http://andyvasile.net/s/demod.sh) -[options] domain.tld rule-id"
        echo
        echo "Options:"
        echo "-d . Disable"
        echo "-e . Enable"
        echo "-l . List (please add a dummy number at the end)"
        echo
        exit 0
}

function restart_apache(){
  # This function is a prototype. Right now it checks apache syntax and ask the user to restart it manually.
  # It will be updated later to restart apache automatially when Syntax is OK.
  #
  httpd -t
  #
  echo
  echo "Please restart Apache if 'Syntax OK' was shown above"
  #
  echo "/scripts/restartsrv_httpd"
  echo
}

if [[ ! $# -eq 3 ]]; then
        #
        # if no parameters, will print the usage & finish the script
        #
        show_help
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
                -*) show_help; break;;
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
restart_apache
