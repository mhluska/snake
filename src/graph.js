(function() {

  if (window.Game == null) window.Game = {};

  Game.Graph = (function() {

    function Graph(neighbours, edgeWeights) {
      var triple, vertex1, vertex2, weight, _base, _base2, _i, _len, _ref;
      this.neighbours = neighbours != null ? neighbours : {};
      this.edgeWeights = edgeWeights != null ? edgeWeights : [];
      this._distanceBetween = {};
      _ref = this.edgeWeights;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        triple = _ref[_i];
        vertex1 = triple[0], vertex2 = triple[1], weight = triple[2];
        if ((_base = this._distanceBetween)[vertex1] == null) _base[vertex1] = {};
        if ((_base2 = this._distanceBetween)[vertex2] == null) {
          _base2[vertex2] = {};
        }
        this._distanceBetween[vertex1][vertex2] = weight;
        this._distanceBetween[vertex2][vertex1] = weight;
      }
    }

    Graph.prototype.distanceBetween = function(vertex1, vertex2) {
      var ret;
      ret = this._distanceBetween[vertex1][vertex2] || Infinity;
      console.log("distanceBetween returning " + ret);
      return ret;
    };

    Graph.prototype.vertices = function() {
      var vertex, _results;
      _results = [];
      for (vertex in this.neighbours) {
        _results.push(vertex);
      }
      return _results;
    };

    Graph.prototype.shortestPath = function(previous, source, target) {
      var path;
      path = [];
      while (previous[target]) {
        path.unshift(target);
        target = previous[target];
      }
      return path;
    };

    Graph.prototype.dijkstras = function(source, target) {
      var alt, closest, distance, neighbour, previous, vertex, vertices, _i, _j, _k, _len, _len2, _len3, _ref, _ref2;
      if (!source) return;
      vertices = this.vertices();
      distance = {};
      previous = {};
      for (_i = 0, _len = vertices.length; _i < _len; _i++) {
        vertex = vertices[_i];
        distance[vertex] = Infinity;
        previous[vertex] = null;
      }
      distance[source] = 0;
      while (vertices.length) {
        closest = vertices[0];
        _ref = vertices.slice(1);
        for (_j = 0, _len2 = _ref.length; _j < _len2; _j++) {
          neighbour = _ref[_j];
          if (distance[neighbour] < distance[closest]) closest = neighbour;
        }
        if (distance[closest] === Infinity) break;
        vertices.splice(vertices.indexOf(closest), 1);
        _ref2 = this.neighbours[closest];
        for (_k = 0, _len3 = _ref2.length; _k < _len3; _k++) {
          neighbour = _ref2[_k];
          if (vertices.indexOf(neighbour) === -1) continue;
          alt = distance[closest] + this.distanceBetween(closest, neighbour);
          if (alt < distance[neighbour]) {
            distance[neighbour] = alt;
            previous[neighbour] = closest;
          }
        }
      }
      if (target) return this.shortestPath(previous, source, target);
      return previous;
    };

    return Graph;

  })();

}).call(this);
