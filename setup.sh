#!/bin/bash

git submodule update --init --recursive

mkdir -p lib

cd src/jquery
npm -g install grunt
npm install
grunt
cd -

ln -fs ../src/jquery/dist/jquery.min.js lib/jquery.min.js

