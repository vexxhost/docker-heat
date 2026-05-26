# SPDX-FileCopyrightText: © 2025 VEXXHOST, Inc.
# SPDX-License-Identifier: GPL-3.0-or-later
# Atmosphere-Rebuild-Time: 2024-06-25T22:49:25Z

FROM ghcr.io/vexxhost/openstack-venv-builder:2024.2@sha256:c368891d938a753ef6fc6b946194566f5abab99beb24cb50637c81a4b159608f AS build
RUN --mount=type=bind,from=heat,source=/,target=/src/heat,readwrite <<EOF bash -xe
uv pip install \
    --constraint /upper-constraints.txt \
        /src/heat
EOF

FROM ghcr.io/vexxhost/python-base:2024.2@sha256:f1b4146d751e118c992dab46a03974935990b605d2a73fd5be6faadd67328615
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
