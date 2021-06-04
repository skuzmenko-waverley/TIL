#!/bin/bash

username="username=$1"
password='password=secret'
filename="$2"

response=`curl -s -X POST -F $username -F $password localhost:8000/auth`
token=`echo $response | jq '.access_token'`

curl -s -o $filename -X GET -H 'Accept: application/json' -H "Authorization: Bearer ${token:1:${#token}-2}" localhost:8000/image

