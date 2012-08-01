#!/bin/bash

git submodule update --init --recursive

mkdir -p lib

cd src/jquery
npm -g install grunt
npm install
grunt
cd -

ln -fs ../src/jquery/dist/jquery.min.js lib
ln -fs ../src/requirejs/require.js lib
ln -fs ../src/mustache.js/mustache.js lib
ln -fs ../src/three.js/build/Three.js lib

