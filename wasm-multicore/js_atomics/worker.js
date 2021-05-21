var GRANULARITY = 100000000;
var NUM_THREADS = 4;
var interval = 3.14;

onmessage = function (event) {
  var mem = event.data.memory;
  var byte_val = new Int32Array(mem);
  var index = event.data.index;
  var buffer = event.data.shared_buffer;
  var bottom = index * (interval / NUM_THREADS);
  var upper = bottom + (interval / NUM_THREADS);
  var sum = 0;
  for (var i = 0; i < GRANULARITY;  i++) {
    var x = bottom + (upper - bottom) / GRANULARITY * i;
    sum += Math.sin(x);
  }
  var num_array = Float32Array.of(sum/GRANULARITY);
  var arr = new Float32Array(buffer);
  arr[index] = sum / GRANULARITY;
  Atomics.add(byte_val, 0, 1);
  Atomics.notify(byte_val, 0);
}



