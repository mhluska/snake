class Tools {
  static run() {
    let passed = 0;
    let total  = 0;
    let error  = null;

    this._tests().forEach(test => {
      try {
        test.call(this);
        passed += 1;
      } catch(e) {
        if (!error) error = e;
      } finally {
        total += 1;
      }
    });

    return [passed, total, error];
  }

  static assert(result) {
    if (!result) {
      throw new Error(`Assertion failed: ${result}`);
    }
  }

  static _tests() {
    let tests = [];
    for (let methodName of Object.getOwnPropertyNames(this)) {
      if (/Test$/.test(methodName)) {
        tests.push(this[methodName]);
      }
    }
    return tests;
  }
}

module.exports = Tools;
