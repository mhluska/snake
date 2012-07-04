(function() {

  window.Test = (function() {

    function Test() {}

    Test.prototype.show = function(value, message) {
      if (message) console.log(message);
      console.log(value);
      return console.log('');
    };

    Test.prototype.assert = function(bool, message) {
      var callerLine, clean, err, errorMessage, getErrorObject, index;
      if (bool) return;
      getErrorObject = function() {
        try {
          throw Error('');
        } catch (err) {
          return err;
        }
      };
      err = getErrorObject();
      callerLine = err.stack.split('\n')[4];
      index = callerLine.indexOf("at ");
      clean = callerLine.slice(index + 2, callerLine.length).split(':')[2];
      errorMessage = "" + clean + ": Test failed";
      if (message) errorMessage += ": " + message;
      console.error(errorMessage);
      return console.log('');
    };

    Test.prototype.equals = function(value1, value2) {
      var type1, type2;
      type1 = this._typeOf(value1);
      type2 = this._typeOf(value2);
      if (type1 !== type2) return false;
      if (type1 === 'object' && type2 === 'object') {
        return console.warn('Object comparison not implemented yet');
      }
      if (type1 === 'array' && type2 === 'array') {
        return this._equalArrays(value1, value2);
      }
      return value1 === value2;
    };

    Test.prototype._typeOf = function(value) {
      var type;
      type = typeof value;
      if (type === 'object') {
        if (!value) return 'null';
        if (value instanceof Array) type = 'array';
      }
      return type;
    };

    Test.prototype._equalArrays = function(array1, array2) {
      var elem, index, _len;
      if (array1.length !== array2.length) return;
      for (index = 0, _len = array1.length; index < _len; index++) {
        elem = array1[index];
        if (!this.equals(elem, array2[index])) return false;
      }
      return true;
    };

    return Test;

  })();

}).call(this);
