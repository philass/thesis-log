let main (gran : f32) (interval : f32) : f32 =
  let xs = scan (+) (0) (replicate (i64.f32 (interval / gran)) gran)
  let res = map (\x -> f32.sin) xs
  in gran * (f32.sum res)


