type EntryPointName = String
type EntryPointType = String
data JSEntryPoint = JSEntryPoint { name :: String,
                                   parameters :: [EntryPointType],
                                   return :: [EntryPointType]
                                 }

javascriptWrapper :: [JSEntryPoint] -> String
javascriptWrapper entryPoints = 
  cwraps ++
  classDef ++
  constructor ++ 
  (unlines $ map jsWrapEntryPoint entryPoints) ++
  endClassDef

  
cwraps :: String
cwraps =
"futhark_context_config_new = Module.cwrap(\n\
  'futhark_context_config_new', 'number', []\n\
);\n\
\n\
futhark_context_new = Module.cwrap(\n\
  'futhark_context_new', 'number', ['number']\n\
);\n\
\n\
futhark_context_sync = Module.cwrap(\n\
  'futhark_context_sync', 'number', ['number']\n\
);\n"

constructor :: String
constructor = 
"  constructor() {\n\
    this.cfg = futhark_context_config_new();\n\
    this.ctx = futhark_context_new(this.cfg);\n\
    console.log(this.ctx);\n\
  }\n"


jsWrapEntryPoint :: JSEntryPoint -> String
jsWrapEntryPoint jse =
  (name jse) ++ "(" ++ tail (unwords [",in" ++ show i | i <- [1..length parameters]]) ++ ") {"

  cwrapEntryPoint (name jse)

  

cwrapEntryPoint :: EntryPointName -> String
cwrapEntryPoint ename = "futhark_" ++ ename ++ " = Module.cwrap(\n\
  'futhark_" ++ ename ++ "', 'number', ['number', 'number', 'number']\n\
);\n"

