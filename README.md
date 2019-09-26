# Svencoop-Point-Entities-Plugin
These are point entities that can be useful when ripenting maps. They function identical to their brush counterparts. This plugin contains the following entities:

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

Known Issues: The example map contains a reference to point_hurt but hasn't been implemented. ( TBD ).

Be sure to check out the example map on usage.
Thanks, and have fun :3
