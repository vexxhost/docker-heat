# SPDX-FileCopyrightText: © 2025 VEXXHOST, Inc.
# SPDX-License-Identifier: GPL-3.0-or-later
# Atmosphere-Rebuild-Time: 2024-06-25T22:49:25Z

FROM ghcr.io/vexxhost/openstack-venv-builder:2026.1@sha256:d4fce582dd5df0f816eacc5fd6e47e5806186fcb74b652fb73479b66aef83f22 AS build
RUN --mount=type=bind,from=heat,source=/,target=/src/heat,readwrite <<EOF bash -xe
uv pip install \
    --constraint /upper-constraints.txt \
        /src/heat
EOF

FROM ghcr.io/vexxhost/python-base:2026.1@sha256:38b3a257ff3e1c846a3696b2cf5716981a724c367b0242d7eb334ffd0100584a
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
