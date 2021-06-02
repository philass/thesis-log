onmessage = function (event) {
  var i = event.data.index;
  var num_workers = event.data.num_workers;
  var signal = new Int32Array(event.data.signal);
  var elements = new Int32Array(event.data.elements);
  var prefix_sum = new Int32Array(event.data.prefix_sum);
  var n = elements.length;
  var partitions = num_workers + 1;
  var stride = n / partitions;

  prefix_sum[i * stride] = elements[i * stride];
  for (var j = i * stride + 1; j < (i+1) * stride; j++) {
    prefix_sum[j] = prefix_sum[j-1] + elements[j];
  }

  if (i === 0) {
    // wait for other num_workers to finish
    var finished = 0;
    while (finished < num_workers - 1) {
      Atomics.wait(signal, 0, finished);
      finished = signal[0];
    }
    var x = 0;
    for (var j = 1; j < partitions; j++) {
      x += prefix_sum[j * stride - 1];
      prefix_sum[j * stride] = x;
    }
    // notify other num_workers to restart
    Atomics.store(signal, 1, 1);
    Atomics.notify(signal, 1, num_workers-1);
  } else {
    // notify worker 0 that we are finished
    Atomics.add(signal, 0, 1);
    Atomics.notify(signal, 0, 1);
    // wait for worker 0
    while (Atomics.wait(signal, 1, 0) != "not-equal") {}
  }

  prefix_sum[(i+1) * stride] = elements[(i+1) * stride] + prefix_sum[(i+1) * stride];
  for (var j = (i+1) * stride + 1; j < (i+2) * stride; j++) {
    prefix_sum[j] = prefix_sum[j-1] + elements[j];
  }
  postMessage("Done!");
}





    




