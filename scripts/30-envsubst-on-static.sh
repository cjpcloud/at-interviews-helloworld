#!/bin/bash

set -e

envsubst < /usr/share/nginx/html/index.html.tmpl > /usr/share/nginx/html/index.html
