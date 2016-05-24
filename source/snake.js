'use strict';

let assert        = require('assert');
let THREE         = require('three');
let Const         = require('./const');
let Voxel         = require('./voxel');
let Queue         = require('./queue');
let Animation     = require('./animation');
let makeVoxelMesh = require('./utils/make-voxel-mesh');
let times         = require('./utils/times');
let assertTruthy  = require('./utils/assert-truthy');
let { Graph }     = require('./graph');

module.exports = class Snake {
  constructor(world, direction, face) {
    this.world    = world;
    this.speed    = 0.15;
    this.face     = face;
    this.size     = 6;
    this.mesh     = this._makeMeshGroup(this.size);
    this.position = this.head.position.toArray();

    this._path      = new Queue();
    this._autoMove  = true;
    this._direction = direction;

    this._animationTail = null;
    this._animationHead = null;
    this._prevTailFace  = this._getTailFace();
  }

  get head() {
    return this.mesh ? this.mesh.children[0] : null;
  }

  get tail() {
    return this.mesh ? this.mesh.children[this.size - 1] : null;
  }

  get direction() {
    return this._direction;
  }

  set direction(vector) {
    assert(vector.length() === 1, 'Non unit vector passed to direction setter.');

    // Disallow movement in opposite directions.
    if (vector.dot(this._direction) !== 0) {
      return;
    }

    this._direction.copy(vector);
    this._autoMove = false;
  }

  move(timeDelta) {
    if (this._animationHead && this._animationHead.animating) {
      this._animationHead.update(timeDelta);
    }

    if (this._animationTail && this._animationTail.animating) {
      this._animationTail.update(timeDelta);
    }

    if ((this._animationHead && this._animationHead.animating) ||
        (this._animationTail && this._animationTail.animating)) {
      return;
    }

    const position = this._nextPositionAuto() || this._moveManual();

    this.world.enable(this.tail.position.toArray());
    this.world.disable(this.head.position.toArray());

    this._resetAnimationHead(new THREE.Vector3(...position));
    this._resetAnimationTail(this.tail.position);

    let voxel = Voxel.findOrCreate(position);
    this._eat(voxel);
    return voxel;
  }

  _resetAnimationHead(end) {
    const headClone = this.head.clone();

    this.mesh.add(headClone);

    this._animationHead = new Animation({
      speed: this.speed,
      start: headClone.position,
      end:   end,
      done:  (end) => {
        this.mesh.remove(headClone);
        this._updateSnakePosition(end.toArray());
        this._animationTail.stop();
        this.tail.position.copy(end);
        this.mesh.children.unshift(this.mesh.children.pop());
      }
    });
  }

  _resetAnimationTail(start) {
    if (this._animationTail) {
      this._animationTail.stop();
    }

    this._animationTail = new Animation({
      speed: this.speed,
      start: start,
      end:   this.mesh.children[this.size - 2].position
    });
  }

  _nextPositionAuto() {
    if (!this._autoMove) {
      return false;
    }

    if (this._path.empty()) {
      // Find new target.
      let start = Voxel.findOrCreate(this.position);
      let path  = Graph.dijkstra(start, node => node.type === 'food');

      if (!path) {
        return false;
      }

      path.shift();

      if (path.length === 0) {
        return false;
      }

      this._path = new Queue(path);
    }

    return this._path.dequeue().position;
  }

  _moveManual() {
    assertTruthy(this.position, this._direction);
    return Voxel.findOrCreate(this.position).next(this._direction).position;
  }

  _makeVoxelMesh(position) {
    return makeVoxelMesh(Const.TILE_SIZE, Const.Colors.SNAKE, position);
  }

  _makeMeshGroup(size) {
    // TODO(maros): Make this not magic.
    let position = [-43.75, -6.25, 106.25];
    let group    = new THREE.Object3D();

    for (let i of times(size)) {
      let meshPosition = [...position];
      meshPosition[1] *= -1;
      meshPosition[1] -= i * Const.TILE_SIZE;

      group.add(this._makeVoxelMesh(meshPosition));
      this.world.disable(meshPosition);
    }

    return group;
  }

  _addEdgeMesh(currentVoxel, targetVoxel) {
    const direction = currentVoxel.directionTo(targetVoxel, { sourcePlane: true });
    const currentVec = new THREE.Vector3(...currentVoxel.position);

    currentVec.add(direction.multiplyScalar(Const.TILE_SIZE));

    const mesh = this._makeVoxelMesh(currentVec.toArray());

    // We add the mesh but rearrange to put it at the start of the array since
    // it becomes the head piece. This is a linear time operation and could be
    // optimized if needed.
    this.mesh.add(mesh);
    this.mesh.children.unshift(this.mesh.children.pop());
    this.size += 1;
  }

  _removeEdgeMesh() {
    this.mesh.remove(this.tail);
    this.size -= 1;
  }

  _getTailFace() {
    assertTruthy(this.tail);
    return Voxel.findOrCreate(this.tail.position.toArray()).face;
  }

  // TODO(maros): This should be the only method that manipulates `this.face`
  // and `this._direction`. Use a setter to enforce it.
  _updateSnakePosition(position) {
    assertTruthy(this.position, this.mesh, this.head);

    let currentVoxel = Voxel.findOrCreate(this.position);
    let targetVoxel  = Voxel.findOrCreate(position);

    assert(currentVoxel.adjacentTo(targetVoxel), 'Current voxel not adjacent to target');

    if (!currentVoxel.face.equals(targetVoxel.face)) {
      this._addEdgeMesh(currentVoxel, targetVoxel);
    }

    if (!this._prevTailFace.equals(this._getTailFace())) {
      this._removeEdgeMesh();
    }

    this._prevTailFace = this._getTailFace();

    this._direction = currentVoxel.directionTo(targetVoxel, { sourcePlane: false });
    this.face       = targetVoxel.face;
    this.position   = position;
  }

  _eat(voxel) {
    if (!voxel) return;

    if (voxel.type === 'food') {
      const mesh = this._makeVoxelMesh(this.tail.position.toArray());
      this.world.disable(voxel);
      this.mesh.add(mesh);
      this.size += 1;

      this._resetAnimationTail(mesh.position);
    }
  }
};
