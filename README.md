# Svencoop-Point-Entities-Plugin
These are point entities that can be useful when ripenting maps. They function identical to their brush counterparts but use mins/maxs for bounds. It's not recommended to use these if you're making an entirely new map aside from the bonus entity ( you can just use the brush conterparts, obviously :P ) This plugin contains the following entities:

# point_trigger
```
  Triggers entities within a defined volume. Can be toggled.
  point_trigger is the base of all point trigger entities
```

# point_teleport
```
  Teleports entities within a defined volume. Can be toggled.
```

# point_wall
```
  A simple invisible wall that blocks things. Can be toggled. 
```

# trigger_dispatchkeyvalue ( bonus entity )
```
  Explicitly dispatches ANY keyvalue to an entity during runtime.
```

# TO INSTALL:
1. download and uzip the contents into the main /svencoop/ or /svencoop_addon/ directory
2. insert this into your default_plugins.txt file:
```
"plugin"
{
   "name" "Point Entities"
   "script" "pointentities"
}
```

# IF YOU ARE DISTRIBUTING A RIPENTED MAP BE SURE TO HAVE THE SERVER OWNERS INSTALL THIS PLUGIN TO AVOID MAPS BEING BROKEN!!! AND MAKE SURE YOU ARE DOWNLOADING THIS PLUGIN FROM HERE AND NOT FROM ANY OTHER SOURCE!!!

Known Issues: The example map contains a reference to point_hurt but hasn't been implemented or finished. ( TBD ).

Be sure to check out the example map on how to use these entities properly.
Thanks, and have fun :3
