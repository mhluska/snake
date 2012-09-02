#!/bin/bash

git submodule update --init --recursive

coffee -c $(find test/ -type f -name '*.coffee') snake.coffee src/*.coffee lib/*.coffee

cd src/jquery
npm install
grunt
cd -

cd src/rjs
node dist.js
cd -

cd src/tweenjs/utils
python builder.py
cd -

mkdir -p lib

ln -fs ../src/jquery/dist/jquery.js lib
ln -fs ../src/requirejs/require.js lib
ln -fs ../src/mustachejs/mustache.js lib
ln -fs ../src/threejs/build/Three.js lib
ln -fs ../src/tweenjs/build/Tween.js lib

node src/rjs/r.js -o src/game.build
