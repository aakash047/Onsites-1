#!/bin/bash

base_dir="$(pwd)"
network_bills="$base_dir/network_bills.txt"
log_file="$base_dir/network_usage.log"
top_users="$base_dir/top_users.txt"
high_bill="$base_dir/high_bill.log"
total_bill=0

declare -A unbilled_user
declare -A top_users

while IFS=' ' read -r time date username ip download upload billing; do
    if [[ -z $unbilled_user[$username] ]]; then
        unbilled_user[$username]=0
    fi
    unbilled_user[$username]=$(( unbilled_user[$username] + ((download + upload) * 5 / 10) ))
done < <(tail -n +2 $log_file)

for user in ${!unbilled_user[@]}; do
    echo "$user ${unbilled_user[$user]}" >> $network_bills
done

sort -k 2 -g -r $network_bills -o $network_bills

awk 'NR<4 {print $0}' $network_bills > $top_users

while read -r name bill;do
    grep -Rnw "$log_file" -e "$name" >> $high_bill
    total_bill=$(( total_bill + bill ))
done < $top_users

echo "the total bill of top 3 users is $total_bill"


