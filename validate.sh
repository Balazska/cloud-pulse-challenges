#!/bin/bash
kubectl run cpcv --restart=Never -i --leave-stdin-open --image=balazska/cloud-pulse-challenge-validator:0.0.6 --overrides="{\"spec\":{\"serviceAccountName\":\"$NEPTUN-sa\",\"containers\":[{\"image\":\"balazska/cloud-pulse-challenge-validator:0.0.6\",\"name\":\"cloud-pulse-challenge-validator\",\"command\": [\"./cloud-pulse-challenge-validator\",\"-c\",\"ch1\"],\"resources\":{\"limits\":{\"cpu\":\"100m\", \"memory\":\"64Mi\"}}}]}}" > /dev/null
kubectl logs cpcv
kubectl delete pod cpcv