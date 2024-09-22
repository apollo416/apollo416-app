#!/bin/bash


while true; do
    for i in {1..5}; do
        aws lambda invoke --function-name qa-main-decision-engine-core-pretty-trout response.json &
    done
    wait
done
