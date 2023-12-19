#!/bin/bash

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P );

cd "${parent_path}";

/bin/bash "${parent_path}/docker_app/elk/start.sh";

chown -cR 999:999 "${parent_path}/data/postgres";
chown -cR 1001:1001 "${parent_path}/data/redis";
chown -cR 1000:1000 "${parent_path}/data/mastodon";
chown -cR 911:911 "${parent_path}/data/elk";
chown -cR 1500:1500 "${parent_path}/data/tor";
chown -cR 65534:65534 "${parent_path}/data/fb_api";

docker-compose up -d --build mastodon;
docker-compose up -d --build elk;
docker-compose up -d --build wkd;
docker-compose up -d --build tor;
docker-compose up -d --build fb_api;
