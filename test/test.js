(function() {
  var equalArrays, typeOf;

  window.show = function(variable, message) {
    if (message) console.log(message);
    console.log(variable);
    return console.log('');
  };

  window.assert = function(exp, message) {
    var callerLine, clean, err, errorMessage, getErrorObject, index;
    if (exp) return;
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

  window.equals = function(val1, val2) {
    var type1, type2;
    type1 = typeOf(val1);
    type2 = typeOf(val2);
    if (type1 !== type2) return false;
    if (type1 === 'object' && type2 === 'object') {
      return console.warn('Object comparison not implemented yet');
    }
    if (type1 === 'array' && type2 === 'array') return equalArrays(val1, val2);
    return val1 === val2;
  };

  typeOf = function(value) {
    var type;
    type = typeof value;
    if (type === 'object') {
      if (!value) return 'null';
      if (value instanceof Array) type = 'array';
    }
    return type;
  };

  equalArrays = function(array1, array2) {
    var elem, index, _len;
    if (array1.length !== array2.length) return;
    for (index = 0, _len = array1.length; index < _len; index++) {
      elem = array1[index];
      if (!equals(elem, array2[index])) return false;
    }
    return true;
  };

}).call(this);
