var num_workers = 9;
var n = 100;
var signal = new SharedArrayBuffer(2 * 4);
var elements = new SharedArrayBuffer(n*4);
var arr = new Int32Array(elements);
for (var i = 0; i < n; i++) {
 arr[i] = i;
}
var prefix_sum = new SharedArrayBuffer(n * 4);
workers = [];

for (var i = 0; i < num_workers; i++) {
  workers.push(new Worker('prefix.js'));
}
var counter = 0;
for (var i = 0; i < num_workers; i++) {
  workers[i].onmessage = function (event) {
    counter += 1;
    if (counter === num_workers) {
      console.log(new Int32Array(prefix_sum));
    }
  }
}
for (var i = 0; i < num_workers; i++) {
  workers[i].postMessage({index : i, 
                          num_workers,
                          signal,
                          elements,
                          prefix_sum
                          });
}
