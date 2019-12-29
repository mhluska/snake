const assert     = require('assert');
const THREE      = require('three');
const LinkedList = require('./linked-list');

class Animation {
  constructor({
    start,
    end,
    easing = 'linear',
    speed = 1,
    time = null,
    step = () => {},
    done = () => {} } = {}) {

    if (time) {
      assert(!start && !end, 'Time parameter is incompatible with start and end vectors');

      const distance = 1;
      time  = time * 1000;
      speed = distance / time;
      start = new THREE.Vector3(0, 0, 0);
      end   = new THREE.Vector3(0, 0, 1);
    } else {
      assert(start && end && speed, 'Animation requires start and end vectors');

      const distance = end.clone().sub(start).length();
      time = distance / speed;
    }

    this.start        = start;
    this.end          = end;
    this.easing       = easing;
    this.speed        = speed;
    this.time         = time;
    this.step         = step;
    this.done         = done;
    this.animating    = true;
    this._timeElapsed = 0;
    this._startClone  = start.clone();
    this._deferred    = [];
  }

  static update(timeDelta) {
    for (let node of this.animations) {
      const animation = node.data;

      if (animation.animating) {
        animation.update(timeDelta);
      } else {
        node.remove();
      }
    }
  }

  static add(options) {
    return this.animations.append(new this(options));
  }

  then(callback) {
    let res;

    const promise = new Promise((resolve) => {
      res = () => resolve(callback());
    });

    this._deferred.push(res);

    return promise;
  }

  stop() {
    if (this.animating) {
      this.start.copy(this.end);
      this.step(1, this.start);
      this.done(this.end);
      this.animating = false;
      for (let resolve of this._deferred) {
        resolve();
      }
    }
  }

  update(timeDelta) {
    if (!this.animating) {
      return;
    }

    this._timeElapsed += timeDelta;

    if (this._timeElapsed >= this.time) {
      this.stop();
    } else {
      this.step(this._timeStep(this._timeElapsed), this.start);
    }
  }

  _timeStep(timeElapsed) {
    const easing = ({
      linear:  this._linearEasing,
      easeOut: this._easeOutEasing
    })[this.easing];

    const direction = this.end.clone().sub(this._startClone);
    const distance  = this.speed * easing(timeElapsed, this.time);

    this.start.copy(this._startClone.clone().add(direction.clone().normalize().multiplyScalar(distance)));

    const remaining = this.end.clone().sub(this.start);

    return 1 - (remaining.length() / (direction.length()));
  }

  _linearEasing(x) {
    return x;
  }

  // Cubic approximation of a bezier transform.
  _easeOutEasing(x, max) {
    x /= max;                // Change input to the range [0, 1]
    x = ((--x) * x * x) + 1; // Apply the transform
    x *= max;                // Back to the range [0, 500]

    return x;
  }
}

Animation.animations = new LinkedList();

module.exports = Animation;
