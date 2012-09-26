#!/bin/bash

git submodule update --init --recursive

coffee -c $(find test/ -type f -name '*.coffee') snake.coffee src/*.coffee lib/*.coffee

# Compile submodules.
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

# Setup library links.
mkdir -p lib
ln -fs ../src/jquery/dist/jquery.js lib
ln -fs ../src/requirejs/require.js lib
ln -fs ../src/mustachejs/mustache.js lib
ln -fs ../src/threejs/build/Three.js lib
ln -fs ../src/tweenjs/build/Tween.js lib

# Compile the client-side code and link it with server code.
node src/rjs/r.js -o src/game.build

mkdir -p server/static
ln -fs ../../build/lib/detector.js server/static
ln -fs ../../build/lib/require.js server/static
ln -fs ../../build/src/game.js server/static
ln -fs ../../build/snake.js server/static
ln -fs ../../build/snake.css server/static
