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

class Snake {
  constructor(world, direction, face, {
      startPosition = Voxel.middleVoxel(face),
      color = Const.Colors.SNAKE,
      type = 'player',
      speed = 0.075
    } = {}) {

    this.world    = world;
    this.speed    = speed;
    this.type     = type;
    this.color    = color;
    this.face     = face;
    this.size     = 6;
    this.mesh     = this._makeMeshGroup(this.size, startPosition, direction);
    this.position = this.head.position;

    this._path      = new Queue();
    this._autoMove  = true;
    this._direction = direction;
    this._moveQueue = new Queue([], this.constructor.MAX_QUEUED_MOVES);

    this._animationTail = null;
    this._animationHead = null;
    this._prevTailFace  = this._getTailFace();
  }

  get eyes() {
    return this.head ? this.head.children : null;
  }

  get head() {
    return this.mesh ? this.mesh.children[0] : null;
  }

  get tail() {
    return this.mesh ? this.mesh.children[this.size - 1] : null;
  }

  enqueueDirection(vector) {
    assert(vector.length() === 1, 'Non unit vector passed to direction setter.');

    const previousVector = this._moveQueue.peek() || this._direction;

    // Disallow movement in opposite directions.
    if (vector.dot(previousVector) !== 0) {
      return;
    }

    this._moveQueue.enqueue(vector);
  }

  die() {
    throw new SnakeDeathError({ snake: this });
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

    if (this._dequeueDirection()) {
      this._autoMove = false;
    }

    const position = this._nextPositionAuto() || this._nextPositionManual();
    const foodMesh = this._eat(Voxel.at(position));

    this._updateDirection(position);
    this._updateEyesOrientation(position);

    this.world.enable(this.tail.position);
    this.world.disable(position, 'snake');

    this._resetAnimationTail(this.tail.position);
    this._resetAnimationHead(new THREE.Vector3(...position));

    return this._animationHead.then(() => foodMesh);
  }

  _dequeueDirection() {
    const vector = this._moveQueue.dequeue();

    if (!vector) {
      return false;
    }

    // NOTE(maros): This will throw an error if the snake has changed to a new
    // face but the direction was enqueued while on the previous face.
    try {
      Voxel.at(this.position).next(vector);
    } catch(error) {
      return false;
    }

    this._direction.copy(vector);

    return true;
  }

  _updateDirection(targetPosition) {
    const currentVoxel = Voxel.at(this.position);
    const targetVoxel  = Voxel.at(targetPosition);

    // TODO(maros): Remove this side effect.
    this.face = targetVoxel.face;

    this._direction.copy(currentVoxel.directionTo(targetVoxel, { sourcePlane: false }));
  }

  _updateEyesOrientation(position) {
    assertTruthy(this.eyes, this._direction);

    const face = Voxel.at(position).face;

    this._setEyeOrientation(this.eyes[1], face, this._direction, 'left');
    this._setEyeOrientation(this.eyes[0], face, this._direction, 'right');
  }

  _resetAnimationHead(end) {
    if (this._animationHead) {
      this._animationHead.stop();
    }

    const headClone = this.head.clone();

    // Since the snake eyes end up in `headClone`, we remove the original ones.
    this.eyes.pop();
    this.eyes.pop();

    this.mesh.add(headClone);

    this._animationHead = new Animation({
      speed: this.speed,
      start: headClone.position,
      end:   end,
      done:  (end) => {
        this.mesh.remove(headClone);
        this._animationTail.stop();
        this._updateSnakePosition(end);
        this.tail.position.copy(end);
        this.mesh.children.unshift(this.mesh.children.pop());
        this._transferEyes(headClone, this.head);
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

    // Recompute path.
    if (this._path.empty() || Voxel.at(this._path.peek().position).type === 'snake') {

      this.world.enable(this.position);

      // Find new target.
      const start = Voxel.at(this.position);
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

    const voxel = Voxel.at(this.position);
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
    return makeVoxelMesh(Const.TILE_SIZE, { color: this.color, position: position });
  }

  _makeMeshGroup(size, startPosition, unitDirection) {
    const group = new THREE.Object3D();

    for (let i of times(size)) {
      const direction = unitDirection.clone().multiplyScalar(i * Const.TILE_SIZE);
      const meshPosition = startPosition.clone().sub(direction);

      group.add(this._makeVoxelMesh(meshPosition));
      this.world.disable(meshPosition, 'snake');
    }

    this._addEyesTo(group.children[0], unitDirection);

    return group;
  }

  _setEyeOrientation(mesh, face, direction, eyeSide) {
    const eyeShift = direction.clone().cross(face);
    const eyeShiftScalar = 4.75;

    if (eyeSide === 'left') {
      eyeShift.negate();
    }

    mesh.position.set(0, 0, 0);
    mesh.lookAt(face);

    // NOTE(maros): We add `0.01` so that the eyes render above the snake
    // meshes. Otherwise there are rendering issues after the snake eats a
    // voxel.
    mesh.position.add(face.clone().multiplyScalar((Const.TILE_SIZE / 2) + 0.01));
    mesh.position.add(eyeShift.multiplyScalar(Const.TILE_SIZE / eyeShiftScalar));
    mesh.position.add(direction.clone().multiplyScalar(Const.TILE_SIZE / eyeShiftScalar));
  }

  _makeEyeMesh(face, direction, eyeSide) {
    const size = Const.TILE_SIZE / 4;
    const geometry = new THREE.PlaneGeometry(size, size);
    const material = new THREE.MeshBasicMaterial({ color: Const.Colors.EYES, side: THREE.DoubleSide });
    const mesh = new THREE.Mesh(geometry, material);

    this._setEyeOrientation(mesh, face, direction, eyeSide);

    return mesh;
  }

  _addEyesTo(mesh, direction) {
    assertTruthy(mesh);

    const face = Voxel.at(mesh.position).face;

    mesh.add(this._makeEyeMesh(face, direction, 'left'),
             this._makeEyeMesh(face, direction, 'right'));
  }

  _transferEyes(fromMesh, toMesh) {
    assert(fromMesh, 'fromMesh missing');
    assert(fromMesh.children.length === 2, 'fromMesh eyes missing');

    if (!toMesh) {
      return;
    }

    toMesh.add(fromMesh.children.pop());
    toMesh.add(fromMesh.children.pop());
  }

  _addEdgeMesh(currentVoxel, targetVoxel) {
    const direction = currentVoxel.directionTo(targetVoxel, { sourcePlane: true });
    const currentVec = new THREE.Vector3(...currentVoxel.position);

    currentVec.add(direction.multiplyScalar(Const.TILE_SIZE));

    const mesh = this._makeVoxelMesh(currentVec);

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
    this.world.enable(this.tail.position);
  }

  _getTailFace() {
    assertTruthy(this.tail);
    return Voxel.at(this.tail.position).face;
  }

  _updateSnakePosition(position) {
    assertTruthy(this.position, this.mesh, this.head);

    const currentVoxel = Voxel.at(this.position);
    const targetVoxel  = Voxel.at(position);

    assert(currentVoxel.adjacentTo(targetVoxel), 'Current voxel not adjacent to target');

    if (!currentVoxel.face.equals(targetVoxel.face)) {
      this._addEdgeMesh(currentVoxel, targetVoxel);
    }

    if (!this._prevTailFace.equals(this._getTailFace())) {
      this._removeEdgeMesh();
    }

    this._prevTailFace = this._getTailFace();
    this.position      = position;
  }

  _eat(voxel) {
    if (!voxel) {
      return;
    }

    if (voxel.type !== 'food') {
      return;
    }

    const mesh = this._makeVoxelMesh(this.tail.position);
    this.mesh.add(mesh);
    this.size += 1;

    this._resetAnimationTail(mesh.position);

    return voxel.mesh;
  }
};

Snake.MAX_QUEUED_MOVES = 2;

module.exports = Snake;

