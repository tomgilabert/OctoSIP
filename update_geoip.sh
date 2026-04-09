#!/bin/bash
# Download/update the MaxMind GeoLite2 databases
source /opt/sipmon/config.conf

DIR=/opt/sipmon/geoip
BASE_URL="https://download.maxmind.com/geoip/databases"

cd "$DIR"

for DB in GeoLite2-City GeoLite2-ASN; do
    curl -fsSL -u "$MAXMIND_ACCOUNT_ID:$MAXMIND_LICENSE_KEY" \
        "$BASE_URL/$DB/download?suffix=tar.gz" -o "$DB.tar.gz" && \
    tar xzf "$DB.tar.gz" --strip-components=1 --wildcards "*/$DB.mmdb" && \
    rm "$DB.tar.gz" && \
    echo "$(date): $DB updated" >> /var/log/geoip_update.log
done

pkill -f sipmon_parser.py
sleep 2
systemctl restart sipmon-api
