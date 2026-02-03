# SPDX-FileCopyrightText: © 2025 VEXXHOST, Inc.
# SPDX-License-Identifier: GPL-3.0-or-later
# Atmosphere-Rebuild-Time: 2024-06-25T22:49:25Z

FROM ghcr.io/vexxhost/openstack-venv-builder:2023.1@sha256:7d208dafdfc09d4a44d4ee7d5e4b02fc2e31d655f217b4aaaacc6bfc55b371c8 AS build
RUN --mount=type=bind,from=heat,source=/,target=/src/heat,readwrite <<EOF bash -xe
uv pip install \
    --constraint /upper-constraints.txt \
        /src/heat
EOF

FROM ghcr.io/vexxhost/python-base:2023.1@sha256:f0f689057c87cbd65fddd0a9ea0da860c76cb604d20c31206d6fccb499e28995
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
