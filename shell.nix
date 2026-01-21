{ pkgs ? import <nixpkgs> {} }:

let
  lua = pkgs.lua5_4;

  patchedBustedDefs = pkgs.writeTextDir "library/busted_patch.lua" ''
    ---@meta
    ---@diagnostic disable: inject-field

    ---@param expected any
    ---@param actual   any
    ---@param message? string
    ---@vararg any
    function assert.equals(expected, actual, message, ...) end
  '';
in
pkgs.mkShell {
  buildInputs = [ lua lua.pkgs.busted ];

  LUA_PATH  = "./?.lua;./src/?.lua;./src/?/init.lua;" +
              "${lua.pkgs.lua}/share/lua/5.4/?.lua;";
  LUA_CPATH = "";

  shellHook = ''
    export PATCHED_BUSTED_DEFS_PATH="${patchedBustedDefs}"
  '';
}
