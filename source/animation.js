'use strict';

let assert = require('assert');

class Animation {
  // `start`:   THREE.Vector3
  // `end`:     THREE.Vector3
  // `update`:  function
  // `done`:    function
  constructor({ start, end, speed = 1, update = this._linearStep, done = () => {} } = {}) {
    assert(start && end, 'Animation created without start and end vectors');

    this.start       = start;
    this.end         = end;
    this.done        = done;
    this.speed       = speed;
    this.animating   = true;
    this._updateStep = update;
    this._deferred   = [];
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

    this._updateStep(this.start, timeDelta);

    if (this.start.equals(this.end)) {
      this.stop();
    }
  }

  _linearStep(x, timeDelta) {
    let distance  = this.speed * timeDelta;
    let remaining = this.end.clone().sub(this.start);

    distance = Math.min(distance, remaining.length());

    this.start.add(remaining.normalize().multiplyScalar(distance));
  }
}

module.exports = Animation;
