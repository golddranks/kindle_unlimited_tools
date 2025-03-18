#!/bin/sh

buffer=20
KINDLE_EXPORT_PATH=${KINDLE_EXPORT_PATH:?}
exported=$(find "$KINDLE_EXPORT_PATH" | wc -l)
borrowed=$exported
echo "Borrowed: $borrowed Exported: $exported"

while :; do
    date -R
    exported=$(find "$KINDLE_EXPORT_PATH" | wc -l)
    while [ "$borrowed" -ge "$((exported + buffer))" ]; do
        sleep 5
    done
    echo "Borrowed: $borrowed Exported: $exported"
    read -r line || exit 0
    echo "https://www.amazon.co.jp/dp/$line?borrow"
    open "https://www.amazon.co.jp/dp/$line?borrow"
    borrowed=$((borrowed+1))
    echo "Borrowed: $borrowed Exported: $exported"
    sleep 60
done
