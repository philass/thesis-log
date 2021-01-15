main = do
  let jse = JSEntryPoint { name = "entry1", parameters = ["i32"], ret = ["u64", "u8"] }
  putStr (javascriptWrapper [jse])

type EntryPointName = String
type EntryPointType = String
data JSEntryPoint = JSEntryPoint { name :: String,
                                   parameters :: [EntryPointType],
                                   ret :: [EntryPointType]
                                 }
initFunc :: String
initFunc = 
  unlines
  [" initData(data) {",
  "    var nDataByes = data.BYTES_PER_ELEMENT",
  "    var dataptr = Module._malloc(nDataBytes);",
  "    var dataHeap = new Uint8Array(Module.HEAPU8.buffer, dataPtr, nDataBytes);",
  "    dataHeap.set(new Uint8Array(data.buffer));",
  "    return dataHeap",
  "}"]

initDataHeap :: Int -> String -> String
initDataHeap idx arrType = "    var dataHeap" ++ show idx ++ " = initData(new " ++ arrType ++ "(1));"


resDataHeap :: Int -> String -> String
resDataHeap idx arrType = 
  "    var res" ++ show idx ++ " = new " ++ arrType ++ "dataHeap" ++ show idx ++ ".buffer," ++
  " dataHeap" ++ show idx ++ ".byteOffset, 1);"
                            
javascriptWrapper :: [JSEntryPoint] -> String
javascriptWrapper entryPoints = unlines 
  [cwraps,
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
   "    console.log(this.ctx);",
   "  }"]


jsWrapEntryPoint :: JSEntryPoint -> String
jsWrapEntryPoint jse =
  unlines
  ["  " ++ func_name ++ "(" ++ args ++ ") {",
  cwrapEntryPoint func_name,
  inits,
  "    futhark_" ++ func_name ++ "(this.ctx, " ++ rets ++ ", " ++ args ++ ");",
  results,  
  "    futhark_context_sync(this.ctx);",
  "    return result[0];"]
  where
    func_name = name jse
    convTypes = map typeConversion $ ret jse
    inits = unlines $ map (\i -> initDataHeap i (convTypes !! i)) [0..(length (ret jse)) - 1]
    results = unlines $ map (\i -> resDataHeap i (convTypes !! i)) [0..(length (ret jse)) - 1]
    rets = tail (unwords [",dataHeap" ++ show i ++ ".byteOffset" | i <- [1..length (parameters jse)]])
    args = tail (unwords [",in" ++ show i | i <- [1..length (parameters jse)]])
    
cwrapEntryPoint :: EntryPointName -> String
cwrapEntryPoint ename = 
  unlines 
  ["    futhark_" ++ ename ++ " = Module.cwrap(", 
   "      'futhark_" ++ ename ++ "', 'number', ['number', 'number', 'number']",
   "    );"]


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
    _ -> "BADTYPE"
