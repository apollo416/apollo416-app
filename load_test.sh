#!/bin/bash


while true; do
    for i in {1..5}; do
        aws lambda invoke --function-name qa-main-decision-engine-core-smashing-porpoise response.json &
    done
    wait
done
