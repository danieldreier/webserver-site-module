#!/bin/bash
siege --concurrent=5 --benchmark --file=long_url_list.txt --time=2m
