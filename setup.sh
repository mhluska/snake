#!/bin/bash

git submodule update --init --recursive

cd src/jquery
npm install
grunt
cd -

cd src/r.js
node dist.js
cd -

mkdir -p lib

ln -fs ../src/jquery/dist/jquery.js lib
ln -fs ../src/requirejs/require.js lib
ln -fs ../src/mustache.js/mustache.js lib
ln -fs ../src/three.js/build/Three.js lib

node src/r.js/r.js -o src/snake.build.js
