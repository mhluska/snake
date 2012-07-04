(function() {

  if (window.Game == null) window.Game = {};

  Game.Graph = (function() {

    function Graph(edgeWeights) {
      var triple, vertex1, vertex2, weight, weightless, _base, _base2, _base3, _base4, _i, _len, _ref;
      this.edgeWeights = edgeWeights != null ? edgeWeights : [];
      weightless = this._weightlessGraph();
      this._distanceBetween = {};
      this._neighbours = {};
      _ref = this.edgeWeights;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        triple = _ref[_i];
        vertex1 = triple[0], vertex2 = triple[1], weight = triple[2];
        if (weightless) weight = 1;
        if ((_base = this._distanceBetween)[vertex1] == null) _base[vertex1] = {};
        if ((_base2 = this._distanceBetween)[vertex2] == null) {
          _base2[vertex2] = {};
        }
        this._distanceBetween[vertex1][vertex2] = weight;
        this._distanceBetween[vertex2][vertex1] = weight;
        if ((_base3 = this._neighbours)[vertex1] == null) _base3[vertex1] = [];
        if ((_base4 = this._neighbours)[vertex2] == null) _base4[vertex2] = [];
        if (vertex1 !== vertex2) {
          this._neighbours[vertex1].push(vertex2);
          this._neighbours[vertex2].push(vertex1);
        }
      }
    }

    Graph.prototype.distanceBetween = function(vertex1, vertex2) {
      return this._distanceBetween[vertex1][vertex2] || Infinity;
    };

    Graph.prototype.vertices = function() {
      var vertex, _results;
      _results = [];
      for (vertex in this._neighbours) {
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
        _ref2 = this._neighbours[closest];
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
      return distance;
    };

    Graph.prototype._weightlessGraph = function() {
      var pair, _i, _len, _ref;
      _ref = this.edgeWeights;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        pair = _ref[_i];
        if (pair.length !== 2) return false;
      }
      return true;
    };

    return Graph;

  })();

}).call(this);
