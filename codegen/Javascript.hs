type EntryPointName = String
type EntryPointType = String
data JSEntryPoint = JSEntryPoint { name :: String,
                                   parameters :: [EntryPointType],
                                   ret :: [EntryPointType]
                                 }
main = do
  let jse = JSEntryPoint { name = "main", parameters = ["[]i32", "f64", "f32"], ret = ["i32", "i64"] }
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


resDataHeap :: Int -> String -> String
resDataHeap idx arrType = 
  "    var res" ++ show idx ++ " = new " ++ arrType ++ "(dataHeap" ++ show idx ++ ".buffer," ++
  " dataHeap" ++ show idx ++ ".byteOffset, 1);"
                            
javascriptWrapper :: [JSEntryPoint] -> String
javascriptWrapper entryPoints = unlines 
  [cwraps,
  unlines $ map (cwrapEntryPoint) entryPoints,
  initFunc,
  classDef,
  constructor,
  (unlines $ map jsWrapEntryPoint entryPoints),
  endClassDef]

  
cwraps :: String
cwraps = 
  unlines
  ["futhark_context_config_new = Module.cwrap(",
   "  'futhark_context_config_new', 'number', []",
   ");",
   "",
   "futhark_context_new = Module.cwrap(",
   "  'futhark_context_new', 'number', ['number']",
   ");",
   "",
   "futhark_context_sync = Module.cwrap(",
   "  'futhark_context_sync', 'number', ['number']",
   ");"]


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
  -- cwrapEntryPoint func_name,
  initArgs,
  inits,
  "    futhark_entry_" ++ func_name ++ "(this.ctx, " ++ rets ++ ", " ++ args2 ++ ");",
  results,  
  "    futhark_context_sync(this.ctx);",
  "    return [" ++ res ++ "];",
  "}"]
  where
    func_name = name jse
    convTypes = map typeConversion $ ret jse
    initArgs = unlines $ map (\i -> initArg i ((parameters jse) !! i)) [0..(length (ret jse)) - 1]
    inits = unlines $ map (\i -> initDataHeap i (convTypes !! i)) [0..(length (ret jse)) - 1]
    results = unlines $ map (\i -> resDataHeap i (convTypes !! i)) [0..(length (ret jse)) - 1]
    rets = tail (unwords [",dataHeap" ++ show i ++ ".byteOffset" | i <- [0..((length (ret jse)) - 1)]])
    args1 = tail (unwords [",in" ++ show i | i <- [0..(length (parameters jse)-1)]])
    args2 = tail (unwords ["," ++ (if (((parameters jse) !! i) !! 0) == '[' then "arr" else "in") ++ show i | i <- [0..(length (parameters jse)-1)]])
    res = tail (unwords [",res" ++ show i ++ "[0]" | i <- [0..((length (ret jse)) - 1)]])

 
    
cwrapEntryPoint :: JSEntryPoint -> String
cwrapEntryPoint jse = 
  unlines 
  ["    futhark_entry_" ++ ename ++ " = Module.cwrap(", 
   "      'futhark_entry_" ++ ename ++ "', 'number', " ++ args,
   "    );"]
   where
    ename = name jse
    arg_length = (length (parameters jse)) + (length (ret jse))
    args = "['number'" ++ (concat (replicate  arg_length ", 'number'")) ++ "]"




initArg :: Int -> EntryPointType -> String
initArg arg_num ep =
  let (i, jstype) = retType ep
  in if i == 0 then ""
            else unlines ["    var inHeap" ++ show arg_num ++ " = initData(in" ++ show arg_num ++ ");",
                            "    var arr" ++ show arg_num ++ " = futhark_" ++ baseType ep ++ "_" ++ show i ++ "d(this.ctx, inHeap" ++ show arg_num ++ ".byteOffset, in" ++ show arg_num ++ ".length);"]



retType :: String -> (Integer, String)
retType ('[':']':end) = 
  let (val, typ) = retType end
  in (val + 1, typ)
retType typ = (0, typeConversion typ)

-- TODO get base type in initArgs
baseType :: String -> String
baseType ('[':']':end) = baseType end
baseType typ = typ

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
