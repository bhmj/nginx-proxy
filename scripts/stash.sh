#!/bin/bash

mkdir -p /tmp/nginx-proxy/configs/
rm -rf /tmp/nginx-proxy/configs/*
mv /var/nginx-proxy/configs/* /tmp/nginx-proxy/configs/ 2>/dev/null || true
rm -rf /var/nginx-proxy/configs/*
