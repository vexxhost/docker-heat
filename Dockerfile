# SPDX-FileCopyrightText: © 2025 VEXXHOST, Inc.
# SPDX-License-Identifier: GPL-3.0-or-later

FROM ghcr.io/vexxhost/openstack-venv-builder:2025.1@sha256:9666de7bd6284b3d75acc03205c896ccb6d5a293764aa910de36aa5b4823d815 AS build
RUN --mount=type=bind,from=heat,source=/,target=/src/heat,readwrite <<EOF bash -xe
uv pip install \
    --constraint /upper-constraints.txt \
        /src/heat
EOF

FROM ghcr.io/vexxhost/python-base:2025.1@sha256:57bad0b4e71c670d7adc73b112810e3afd09ba56527db9f94d82876eef0df823
RUN \
    groupadd -g 42424 heat && \
    useradd -u 42424 -g 42424 -M -d /var/lib/heat -s /usr/sbin/nologin -c "Heat User" heat && \
    mkdir -p /etc/heat /var/log/heat /var/lib/heat /var/cache/heat && \
    chown -Rv heat:heat /etc/heat /var/log/heat /var/lib/heat /var/cache/heat
RUN <<EOF bash -xe
apt-get update -qq
apt-get install -qq -y --no-install-recommends \
    curl jq
apt-get clean
rm -rf /var/lib/apt/lists/*
EOF
COPY --from=build --link /var/lib/openstack /var/lib/openstack
