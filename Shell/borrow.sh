#!/bin/sh

while :; do
    for i in $(seq 10); do
        read line || exit 0
        echo "https://www.amazon.co.jp/dp/$line?borrow"
        open "https://www.amazon.co.jp/dp/$line?borrow"
    done
    sleep 240
    date -R
done
