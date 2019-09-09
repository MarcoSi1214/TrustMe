#!/bin/bash

#  TrustMe
#
#  Created by TrustMe 2018-11-11.
#  Copyright © 2018 TrustMe. All rights reserved.
#  XXX: software licence??

# defaults
cmd="$0"
offline=0
site=""
data="data"

# usage and help
print_usage () {
echo "usage:"
echo "  $cmd (-h|--help)"
echo "  $cmd [-o|--offline] [--] <site>"
echo
}
print_help () {
echo "arguments:"
echo
echo "  <site>          query string (domain name)"
echo
echo "  -o --offline    fetch information from local files"
echo "                  (./<site>.{whois,json,openssl})"
echo
}

# arg parse
while [ $# -ge 1 ]
do
if [ "$DEBUG" = "1" ]
then
1>&2 echo "num: $#, arg: $1"
fi
case $1
in
-h | --help)
print_usage
print_help
exit 0
;;
-o | --offline)
offline=1
shift
;;
--)
if [ -n "$site" ]
then
1>&2 echo "$cmd: error: multiple non-option arguments."
1>&2 print_usage
exit 1
fi
site=$2
shift
shift
;;
-*)
1>&2 echo "$cmd: error: invalid argument. '$1'"
1>&2 print_usage
exit 1
;;
*)
if [ -n "$site" ]
then
1>&2 echo "$cmd: error: multiple non-option arguments."
1>&2 print_usage
exit 1
fi
site=$1
shift
;;
esac
done

# test arg parse
if [ "$DEBUG" = "1" ]
then
1>&2 echo "offline: $offline"
1>&2 echo "site:    $site"
fi

# input information
whois_file="$data/$site.whois"
curl_file="$data/$site.json"
openssl_file="$data/$site.openssl"
if [ ! -d "$data" ]
then
mkdir -p "$data"
fi
if [ "$offline" = "1" ]
then
# pre-prepared files
if [ ! -f $whois_file ]
then
1>&2 echo "$cmd: error: file '$whois_file' not found."
exit 1
fi
if [ ! -f $curl_file ]
then
1>&2 echo "$cmd: error: file '$curl_file' not found."
exit 1
fi
if [ ! -f $openssl_file ]
then
1>&2 echo "$cmd: error: file '$openssl_file' not found."
exit 1
fi
else

#ping -c 1 "$site" 2&> /dev/null
#echo "$ping_result"
#if [ $? -ne 0 ]
#then
#echo -e "Sorry\nThe site you provided does not exist.\nPlease go back and try again"
#exit
#fi
function check {
    if [ $? -ne 0 ]
        then
        echo "Sorry, the webpage you provided does not exist or is not available at the moment
"
        exit 1
    fi
}

httpSite="http://$site";
curl -s $site > /dev/null
check;

# fetch information about the domain name
curl -X GET ip-api.com/json/$site 2> /dev/null > $curl_file
whois $site | tr -d '\r' > $whois_file
openssl s_client -servername $site -connect $site:443 \
< /dev/null 2> /dev/null > $openssl_file

fi

# extract organisation and location information from whois
whois_org=$(grep "[Oo]rgani[sz]ation: " $whois_file \
| sed 's/[^:]*: *//' | sort -u)
temp="$IFS"
IFS="
"
for line in $(grep -A 1 "[Aa]ddress: " $whois_file)
do
if [ "$(echo "$line" | sed -e 's/:.*/:/')" = "address:" ]
then
whois_address="$whois_address $(echo "$line" \
| sed -e 's/address: *//')"
else
whois_address="$whois_address$IFS"
fi
done
IFS="$temp"
temp=
whois_address=$(echo "$whois_address" | grep -v '^$' | sed 's/^ //' \
| sort -u)
whois_country=$(grep "[Cc]ountry: " $whois_file | sed 's/[^:]*: *//' \
| sort -u)
whois_city=$(grep "[Cc]ity: " $whois_file | sed 's/[^:]*: *//' \
| sort -u)
whois_state=$(grep "[Ss]tate: " $whois_file | sed 's/[^:]*: *//' \
| sort -u)
whois_province=$(grep "[Pp]rovince: " $whois_file | sed 's/[^:]*: *//' \
| sort -u)
if [ -n "$whois_state" ]
then
whois_location="$whois_state, $whois_country"
elif [ -n "$whois_province" ]
then
whois_location="$whois_province, $whois_country"
elif [ -n "$whois_city" ]
then
whois_location="$whois_city, $whois_country"
elif [ -n "$whois_address" ]
then
whois_location="$whois_address"
elif [ -n "$whois_country" ]
then
whois_location="$whois_country"
else
whois_location="(unknown location)"
fi

# extract organisation and location information from JSON
curl_org=$(cat $curl_file | sed 's/.*"org":"\([^"]*\)".*/\1/' \
| sort -u)
curl_location=$(cat $curl_file \
| sed 's/.*"city":"\([^"]*\)","country":"\([^"]*\)".*/\1, \2/' \
| sort -u)

# extract certificate chain information from openssl request
if [ -n "$(which tac)" ]
then
reverse="tac"
else
reverse="tail -r"
fi
certs=$(grep "i:.*[Cc][Nn]=" $openssl_file | sed 's/.*[Cc][Nn]=//' \
| $reverse)
if [ -z "$certs" ]
then
certs="(no certificate chain information)"
fi

#get dig info
dig_ip=$(dig "$site" +short | tail -1)
dig_info=$(dig -x "$dig_ip" +short)


# print
#echo "You requested the domain name:"
#echo "$site"
#echo
#echo "You received a site from the following organisations:"
#echo "$curl_org"
#echo "$whois_org"
#echo
#echo "Your requested domain name resides in the following location:"
#echo "$whois_location"
#echo
#echo "You received a site from the following location:"
#echo "$curl_location"
#echo
#echo "The certificate chain is as follows:"
#echo "$certs"
if [ "$dig_info" = "" ]
then
echo -e "You requested the domain name:\n$site\n\nYou received a site from the following organisations:\n$curl_org\n$whois_org\n\nYour requested domain name resides in the following location:\n$whois_location\n\nYou received a site from the following location:\n$curl_location\n\nThe certificate chain is as follows:\n$certs"
else
echo -e "You requested the domain name:\n$site\n\nYou received a site from the following organisations:\n$curl_org($dig_info)\n$whois_org\n\nYour requested domain name resides in the following location:\n$whois_location\n\nYou received a site from the following location:\n$curl_location\n\nThe certificate chain is as follows:\n$certs"
fi
exit 0

