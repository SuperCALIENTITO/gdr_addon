 if SERVER then
   AddCSLuaFile()
   AddCSLuaFile("gdr/cl_main.lua")
   include("gdr/sv_main.lua")
 else
   include("gdr/cl_main.lua")
 end