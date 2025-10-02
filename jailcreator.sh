#!/bin/bash
   ssh-keygen -f "/root/.ssh/known_hosts" -R "172.18.0.10"
   docker compose up -d --build
