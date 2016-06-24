const assert              = require('assert');
const THREE               = require('three');
const Const               = require('./const');
const Voxel               = require('./voxel');
const Queue               = require('./queue');
const Animation           = require('./animation');
const makeVoxelMesh       = require('./utils/make-voxel-mesh');
const times               = require('./utils/times');
const assertTruthy        = require('./utils/assert-truthy');
const { Graph }           = require('./graph');
const { SnakeDeathError } = require('./error');

module.exports = class Snake {
  constructor(world, direction, face, { startPosition = null, color = Const.Colors.SNAKE, type = 'player' } = {}) {
    if (!startPosition) {
       startPosition = Voxel.middleVoxel(face);
    }

    this.world    = world;
    this.speed    = 0.15;
    this.type     = type;
    this.color    = color;
    this.face     = face;
    this.size     = 6;
    this.mesh     = this._makeMeshGroup(this.size, startPosition, direction);
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

    this._animationHead.then(() => {
      this._direction.copy(vector);
      this._autoMove = false;
    });
  }

  die() {
    throw new SnakeDeathError();
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

    const position = this._nextPositionAuto() || this._nextPositionManual();
    const voxel = Voxel.findOrCreate(position);
    const foodMesh = this._eat(voxel);

    this.world.enable(this.tail.position.toArray());
    this.world.disable(position, 'snake');

    this._resetAnimationTail(this.tail.position);
    this._resetAnimationHead(new THREE.Vector3(...position));

    return this._animationHead.then(() => foodMesh);
  }

  _resetAnimationHead(end) {
    if (this._animationHead) {
      this._animationHead.stop();
    }

    const headClone = this.head.clone();

    this.mesh.add(headClone);

    this._animationHead = new Animation({
      speed: this.speed,
      start: headClone.position,
      end:   end,
      done:  (end) => {
        this.mesh.remove(headClone);
        this._animationTail.stop();
        this._updateSnakePosition(end.toArray());
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

  // TOOD(maros): If this is inefficient, react to a world food drop event
  // instead.
  _nextPositionAuto() {
    if (!this._autoMove) {
      return false;
    }

    // Recompute path.
    if (this._path.empty() || Voxel.findOrCreate(this._path.peek()).type === 'snake') {

      this.world.enable(this.position);

      // Find new target.
      const start = Voxel.findOrCreate(this.position);
      this._path  = new Queue(Graph.dijkstra(start, node => node.type === 'food'));

      // Remove the current position.
      this._path.dequeue();

      this.world.disable(this.position, 'snake');
    }

    if (this._path.empty()) {
      return false;
    }

    return this._path.dequeue().position;
  }

  _nextPositionManual() {
    assertTruthy(this.position, this._direction);

    const voxel = Voxel.findOrCreate(this.position);
    const nextVoxel = voxel.next(this._direction);

    if (this.type === 'player' && nextVoxel.type === 'snake' && !this._autoMove) {
      return this.die();
    }

    if (nextVoxel.type === 'snake') {
      for (let neighbor of voxel._next.values()) {
        if (neighbor.type !== 'snake') {
          return neighbor.position;
        }
      }

      return this.die();
    } else {
      return nextVoxel.position;
    }
  }

  _makeVoxelMesh(position) {
    return makeVoxelMesh(Const.TILE_SIZE, this.color, position);
  }

  _makeMeshGroup(size, startPosition, unitDirection) {
    const group = new THREE.Object3D();

    for (let i of times(size)) {
      const direction = unitDirection.clone().multiplyScalar(i * Const.TILE_SIZE);
      const meshPosition = startPosition.clone().sub(direction).toArray();

      group.add(this._makeVoxelMesh(meshPosition));
      this.world.disable(meshPosition, 'snake');
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

    // NOTE(maros): This is the new tail after updating `this.size`.
    this.world.enable(this.tail.position.toArray());
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
    this._direction    = currentVoxel.directionTo(targetVoxel, { sourcePlane: false });
    this.face          = targetVoxel.face;
    this.position      = position;
  }

  _eat(voxel) {
    if (!voxel) return;

    if (voxel.type === 'food') {
      const mesh = this._makeVoxelMesh(this.tail.position.toArray());
      this.mesh.add(mesh);
      this.size += 1;

      this._resetAnimationTail(mesh.position);

      return voxel.mesh;
    }
  }
};
