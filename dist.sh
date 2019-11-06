#!/bin/bash -e

grep -P '^ID=' /etc/os-release | awk -F= '{print $2}' | tr -d '"'
