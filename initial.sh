#!/bin/bash

# Eventually: for i in `ls`; do tar xf $i; done
grep -R fail ${tar_file}/var/log
