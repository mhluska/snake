class Tools {
  static run(moduleName) {
    let passed = 0;
    let total  = 0;
    let error  = null;

    console.log(`Running ${moduleName} tests...`);

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

    if (passed === total) {
      console.log('All tests passed');
    } else {
      console.log(`${passed}/${total} tests passed.`);
      throw error;
    }

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
