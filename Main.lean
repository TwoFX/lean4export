import Export
open Lean

def semver := "markus-0.0.5"

def main (args : List String) : IO Unit := do
  initSearchPath (← findSysroot)
  let (imports, constants) := args.span (· != "--")
  let imports := imports.toArray.map fun mod => { module := Syntax.decodeNameLit ("`" ++ mod) |>.get! }
  let env ← importModules imports {}
  let constants := match constants.tail? with
    | some cs => cs.map fun c => Syntax.decodeNameLit ("`" ++ c) |>.get!
    | none    => env.constants.toList.map Prod.fst |>.filter (!·.isInternal)
  M.run env do
    IO.println semver
    for c in constants do
      let _ ← dumpConstant c
