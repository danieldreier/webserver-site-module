#!/bin/bash
for time in 5m 10m 15m
do
  for concurrency in 3 5 10
    do
  siege --concurrent=${concurrency} --benchmark --file=long_url_list.txt --time=${time} >> benchmark_concurrency_${concurrency}_time_${time}.out
    done
done
