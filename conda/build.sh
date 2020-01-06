#!/bin/bash

cp -R $SRC_DIR/* $PREFIX/
ls $PREFIX

cp $SRC_DIR/conda/.env.conda $PREFIX/.env
chmod 666 $PREFIX/logstash/sandbox/settings/logstash.yml

mkdir $PREFIX/bin
cp $SRC_DIR/conda/run-engine.sh $PREFIX/bin/engine.sh
chmod ug+x $PREFIX/bin/engine.sh

mkdir -p $PREFIX/mydig-projects/.es/data
