var GRANULARITY = 1000000000;
var NUM_THREADS = 4;
var interval = 3.14;

onmessage = function (event) {
  var index = event.data;
  var bottom = index * (interval / NUM_THREADS);
  var upper = bottom + (interval / NUM_THREADS);
  var sum = 0;
  for (var i = 0; i < GRANULARITY;  i++) {
    var x = bottom + (upper - bottom) / GRANULARITY * i;
    sum += Math.sin(x);
  }
  var res = sum / GRANULARITY;
  postMessage(res);
}



