#!/usr/bin/env bash

# gen base64 gfwlist
echo -e "\nDelete old base64 file gfwlist.txt"
rm -rf gfwlist.txt
echo -e "\nGen new gfwlist.txt..."
result=`which base64`
if [ -z "$result" ]; then
    echo "Please install base64 first!"
    exit
fi
base64 -b 64 -i domains.txt -o gfwlist.txt
echo -e "\nGen new gfwlist.txt... Done\n"

# gen gfwlist dnsmasq rules
./scripts/gfwlist2dnsmasq.sh -l -o gfwlist_domains.txt
./scripts/gfwlist2dnsmasq.sh -p 7913 -o gfwlist_dnsmasq.txt
./scripts/gfwlist2dnsmasq.sh -p 7913 -s gfwlist -o gfwlist_dnsmasq_ipset.txt

# push to github
git tag -d v1.0
git push origin :refs/tags/v1.0
git add .
git commit -m "update by shell"
git tag -a v1.0 -m "Release V1.0"
git push origin master
git push origin v1.0