(function() {

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

}).call(this);
