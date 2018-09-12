#!/bin/bash -e

BASE_HREF="${BASE_HREF:-}";

# Ensure NGINX is running
ps $(cat /var/run/nginx.pid) > /dev/null 2>&1;

status=$(curl \
  -s -o /tmp/healthcheck.html \
  -w "%{http_code}" \
  --header "User-Agent: healthcheck" \
  http://localhost:8080${BASE_HREF}/healthcheck.html \
);

changes=$(diff /tmp/healthcheck.html /usr/share/nginx/html/healthcheck.html \
  | wc -l \
);

rm -f /tmp/healthcheck.html;

if [[ $status -ne 200 || changes -ne 0 ]]; then
  echo 'Healthcheck request failed.';
  exit 1;
fi

status=$(curl \
  -s -o /tmp/healthcheck.html \
  -w "%{http_code}" \
  --header "User-Agent: healthcheck" \
  http://localhost:8080${BASE_HREF}/bad_request.html \
);

changes=$(diff /tmp/healthcheck.html /usr/share/nginx/html/404.html | wc -l);
rm -f /tmp/healthcheck.html;

if [[ $status -ne 404 || changes -ne 0 ]]; then
  echo 'Error check failed.';
  exit 1;
fi

echo 'Container is healthy.';
exit 0;