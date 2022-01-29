FROM nginx:latest

ARG GIT_COMMIT=unspecified
LABEL git_commit=$GIT_COMMIT
ENV GIT_COMMIT=$GIT_COMMIT

RUN apt-get update && apt-get upgrade -o Dpkg::Options::='--force-confold' -y \
  && apt-get install -y --no-install-recommends gettext-base \
  && apt autoremove -y \
  && rm -rf /var/lib/apt/lists/* 

COPY scripts/30-envsubst-on-static.sh /docker-entrypoint.d
COPY static /usr/share/nginx/html
