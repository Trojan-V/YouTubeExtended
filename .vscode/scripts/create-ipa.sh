#!/usr/bin/env bash
set -e

cyan -i YouTube.ipa -o YouTubeExtended.ipa -uwef packages/* -n YouTube -b com.google.ios.youtube
