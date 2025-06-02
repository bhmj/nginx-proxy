#!/bin/bash

mkdir -p /tmp/nginx-proxy/configs/
rm -rf /tmp/nginx-proxy/configs/*
mv /var/nginx-proxy/configs/* /tmp/nginx-proxy/configs/
rm -rf /var/nginx-proxy/configs/*
