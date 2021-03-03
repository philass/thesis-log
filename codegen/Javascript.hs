import Data.List 

type EntryPointName = String
type EntryPointType = String
data JSEntryPoint = JSEntryPoint { name :: String,
                                   parameters :: [EntryPointType],
                                   ret :: [EntryPointType]
                                 }
main = do
  let jse = JSEntryPoint { name = "main", parameters = ["[]i64"], ret = ["[]i64"] }
  putStr (javascriptWrapper [jse])



initFunc :: String
initFunc = 
  unlines
  [" function initData(data) {",
  "    var nDataBytes = data.length * data.BYTES_PER_ELEMENT",
  "    var dataPtr = Module._malloc(nDataBytes);",
  "    var dataHeap = new Uint8Array(Module.HEAPU8.buffer, dataPtr, nDataBytes);",
  "    dataHeap.set(new Uint8Array(data.buffer));",
  "    return dataHeap",
  "}"]

initDataHeap :: Int -> String -> String
initDataHeap idx arrType = "    var dataHeap" ++ show idx ++ " = initData(new " ++ arrType ++ "(1));"

dataHeapConv :: String -> String -> String
dataHeapConv size arrType = 
  "    var dataHeapRes = new " ++ arrType ++ "(dataHeap.buffer, dataHeap.byteOffset, " ++ size ++ ");"

resDataHeap :: Int -> String -> String
resDataHeap idx arrType = 
  "    var res" ++ show idx ++ " = new " ++ arrType ++ "(dataHeap" ++ show idx ++ ".buffer," ++
  " dataHeap" ++ show idx ++ ".byteOffset, 1);"
                            
javascriptWrapper :: [JSEntryPoint] -> String
javascriptWrapper entryPoints = unlines 
  [cwraps,
   cwrapsJSE entryPoints,
  unlines $ map (cwrapEntryPoint) entryPoints,
  initFunc,
  classDef,
  constructor,
  unlines $ concatMap (\jse -> map toFutharkArray (parameters jse)) entryPoints,
  unlines $ concatMap (\jse -> map fromFutharkArrayShape (ret jse)) entryPoints,
  --unlines $ concatMap (\jse -> map fromFutharkArrayRawValues (ret jse)) entryPoints,
  unlines $ concatMap (\jse -> map fromFutharkArrayValues(ret jse)) entryPoints,
  (unlines $ map jsWrapEntryPoint entryPoints),
  endClassDef]

  
cwraps :: String
cwraps =
  unlines
  [ cwrapFun "futhark_context_config_new" 0,
    cwrapFun "futhark_context_new" 1,
    cwrapFun "futhark_context_sync" 1
  ]

-- TODO Only wrap functions for first params
cwrapsJSE :: [JSEntryPoint] -> String
cwrapsJSE jses =
    unlines $ 
    map (\arg -> cwrapFun (gfn "new" arg) ((dim arg) + 2)) jses' ++
    map (\arg -> cwrapFun (gfn "shape" arg) ((dim arg) + 2)) jses' ++
    map (\arg -> cwrapFun (gfn "values_raw" arg) ((dim arg) + 2)) jses' ++
    map (\arg -> cwrapFun (gfn "values" arg) 2) jses'
  where
    jses' = filter (\t -> dim t >  0) $ nub $ concatMap (\jse -> (parameters jse) ++ (ret jse)) jses
    gfn typ str = "futhark_" ++ typ ++ "_" ++ baseType str ++ "_" ++ show (dim str) ++ "d"
  
  

cwrapFun :: String -> Int -> String
cwrapFun fname numArgs =
  unlines
  [
  fname ++ " = Module.cwrap(",
  "  '" ++ fname ++ "', 'number', [" ++ intercalate ", " (replicate numArgs "'number'") ++ "]",
  ");"
  ]


  
classDef :: String
classDef = "class FutharkContext {"

endClassDef :: String
endClassDef = "}"

constructor :: String
constructor = 
  unlines
  ["  constructor() {",
   "    this.cfg = futhark_context_config_new();",
   "    this.ctx = futhark_context_new(this.cfg);",
   "  }"]


jsWrapEntryPoint :: JSEntryPoint -> String
jsWrapEntryPoint jse =
  unlines
  ["  " ++ func_name ++ "(" ++ args1 ++ ") {",
  --inits,
  initPtrs,
  "    futhark_entry_" ++ func_name ++ "(this.ctx, " ++ rets ++ ", " ++ args1 ++ ");",
  results,  
  "    futhark_context_sync(this.ctx);",
  "    return [" ++ res ++ "];",
  "  }"]
  where
    func_name = name jse
    alr = [0..(length (ret jse)) - 1]
    alp = [0..(length (parameters jse)) - 1]
    convTypes = map typeConversion $ ret jse
    --inits = unlines $ map (\i -> initDataHeap i (convTypes !! i)) alr
    initPtrs = unlines $ map (\i -> initPtr i (ret jse !! i)) alr
    results = unlines $ map (\i -> if (ret jse !! i) !! 0 == '[' then "" else resDataHeap i (convTypes !! i)) alr
    rets = intercalate ", " [retPtrOrOther i jse "dataHeap" ".byteOffset" ptrRes | i <- alr]
    args1 = intercalate ", " ["in" ++ show i | i <- alp]
    res = intercalate ", " [retPtrOrOther i jse "res" "[0]" ptrResValue | i <- alr]
    ptrRes i _ = "res" ++ show i
    ptrResValue i _ = "getValue(res" ++ show i ++ ", 'i32')"
    retPtrOrOther i jse pre post f = if ((ret jse) !! i) !! 0 == '[' 
                                  then f i $ (ret jse) !! i
                                  else pre ++ show i ++ post

cwrapEntryPoint jse = 
  unlines 
  ["    futhark_entry_" ++ ename ++ " = Module.cwrap(", 
   "      'futhark_entry_" ++ ename ++ "', 'number', " ++ args,
   "    );"]
   where
    ename = name jse
    arg_length = (length (parameters jse)) + (length (ret jse))
    args = "['number'" ++ (concat (replicate  arg_length ", 'number'")) ++ "]"


initPtr :: Int -> EntryPointType -> String
initPtr argNum ep =
  let (i, jstype) = retType ep
  in 
    if i == 0 
    then "" else 
    makePtr argNum

makePtr :: Int -> String 
makePtr i = "    var res" ++ show i ++ " = Module._malloc(8);"

retType :: String -> (Integer, String)
retType ('[':']':end) = 
  let (val, typ) = retType end
  in (val + 1, typ)
retType typ = (0, typeConversion typ)

baseType :: String -> String
baseType ('[':']':end) = baseType end
baseType typ = typ

dim :: String -> Int
dim ('[':']':end) = (dim end) + 1
dim typ = 0

jsType = (snd . retType)

typeConversion :: String -> String
typeConversion typ =
  case typ of 
    "i8" -> "Int8Array"
    "i16" -> "Int16Array"
    "i32" -> "Int32Array"
    "i64" -> "BigInt64Array"
    "u8" -> "Uint8Array"
    "u16" -> "Uint16Array"
    "u32" -> "Uint32Array"
    "u64" -> "BigUint64Array"
    "f32" -> "Float32Array"
    "f64" -> "Float64Array"
    _ -> typ


toFutharkArray :: String -> String
toFutharkArray str =
  if dim str == 0
  then ""
  else
  unlines
  ["to_futhark_" ++ ftype ++ "_" ++ show i ++  "d_arr(" ++ intercalate ", " args1 ++ ") {",
   -- "  // Possibly do sanity check that dimensions dim0 * dimn == arr.length",
   "  var dataHeap = initData(arr);",
   "  var fut_arr = futhark_new_" ++ ftype ++ "_" ++ show i ++ "d(" ++ intercalate ", " args2 ++ ");",
   "  return fut_arr;",
   "}"]
  where
  ctx = "this.ctx"
  arr = "arr"
  ofs = "dataHeap.byteOffset"
  i = dim str
  dims = map (\i -> "dim" ++ show i) [0..i-1]
  args1 = [arr] ++ dims
  args2 = [ctx, ofs] ++ dims
  ftype = baseType str

fromFutharkArrayShape :: String -> String
fromFutharkArrayShape str =
  if dim str == 0
  then ""
  else
  unlines
  ["from_futhark_shape_" ++ftype ++ "_" ++ show i ++  "d_arr(futhark_arr) {",
   "  var ptr = futhark_shape_" ++ ftype ++ "_" ++ show i ++ "d(" ++ intercalate ", " args1 ++  ");",
   "  var dataHeap = new Uint8Array(Module.HEAPU8.buffer, ptr, 8 * "++ show i ++ ");",
   " var result = new BigInt64Array(dataHeap.buffer, dataHeap.byteOffset, " ++ show i ++ ");",
   " return result;",
   "}"]
  where
    ctx = "this.ctx"
    arr = "futhark_arr"
    dims = map (\i -> "dim" ++ show i) [0..i-1]
    args1 = [ctx, arr]
    i = dim str
    ftype = baseType str

fromFutharkArrayValues :: String -> String
fromFutharkArrayValues str = 
  if dim str == 0
  then ""
  else
  unlines
  ["from_futhark_values_" ++ftype ++ "_" ++ show i ++  "d_arr(" ++ intercalate ", " args1 ++ ") {",
   -- Possibly do sanity check that dimensions dim0 * dimn == arr.length",
   "  var dims = this.from_futhark_shape_" ++ ftype ++ "_" ++ show i ++ "d_arr(fut_arr);",
   "  var length = Number(dims.reduce((a, b) => a * b));",
   "  var dataHeap = initData(new " ++ arrType ++ "(length));",
   "  futhark_values_" ++ ftype ++ "_" ++ show i ++ "d(" ++ intercalate ", " args2 ++ ");",
   dataHeapConv "length" arrType,
   "  return dataHeapRes;",
   "}"]
  where
  ctx = "this.ctx"
  fut_arr = "fut_arr"
  ptr = "ptr"
  ofs = "dataHeap.byteOffset"
  dims = map (\i -> "dim" ++ show i) [0..i-1]
  args1 = [fut_arr]
  args2 = [ctx, fut_arr, ofs]
  i = dim str
  ftype = baseType str
  arrType = jsType str
