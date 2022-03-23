#!/bin/bash

for var in `cat ./generated/env-variables|grep -v _HOSTS|grep -v _IDS`
do
export $var
done