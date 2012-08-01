#!/bin/bash

git submodule update --init --recursive

mkdir -p lib

cd src/jquery
npm install
grunt
cd -

ln -fs ../src/jquery/dist/jquery.js lib
ln -fs ../src/requirejs/require.js lib
ln -fs ../src/mustache.js/mustache.js lib
ln -fs ../src/three.js/build/Three.js lib

chown -R ${USER}:${USER} .

