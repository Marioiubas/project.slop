# PROJECT ODDVAULT / GRAB THE WEIRD!
# MASTER WORLD, MAP, RIFT & DIMENSION DESIGN SPECIFICATION

You are acting as the lead Roblox world architect, level designer, technical environment designer, procedural-generation engineer, gameplay systems engineer, and art-direction engineer for a commercial Roblox game currently titled:

GRAB THE WEIRD!

The overall game blueprint already exists.

Your current responsibility is specifically to design and implement the WORLD ARCHITECTURE:

- hub/world layout
- player museum spatial system
- Rift system
- dimensions
- modular level kits
- procedural/semi-procedural generation
- extraction routes
- portal transitions
- traversal metrics
- spatial pacing
- environmental hazards
- map streaming
- networking considerations
- performance constraints
- future dimension extensibility

The game fantasy is:

Players enter unstable portals into bizarre alternate dimensions, physically recover strange artifacts, survive the dimension becoming increasingly unstable, and escape with those artifacts to display them in their personal museum.

The central game sentence remains:

"Jump through a portal. Grab something weird. Get it home alive."

Everything about map design must reinforce that sentence.

Do NOT design conventional open-world Roblox maps.

Do NOT build giant empty environments simply because Roblox permits large maps.

Do NOT make Rifts merely visual reskins.

Each dimension must behave differently enough that entering a new Rift feels like learning a new world's physical rules.

The player should eventually recognize dimensions from their silhouettes, movement rules, lighting, sounds, artifact behaviour, hazards, and extraction rhythm alone.

---

# 1. PRIMARY DESIGN PHILOSOPHY

The world architecture should operate at three spatial layers:

LAYER 1 — HUB / HOME

Safe.
Persistent.
Readable.
Social.
Stable.

This is where players:

- spawn
- interact with their museum
- display artifacts
- see other players
- form parties
- manage progression
- inspect collections
- prepare expeditions
- enter Rifts

LAYER 2 — RIFT EXPEDITIONS

Dangerous.
Temporary.
Short.
Unpredictable.
Replayable.

This is the core gameplay environment.

Target baseline Rift run duration:

2–5 minutes.

High-level special Rifts may eventually exceed this, but the normal experience should remain compatible with Roblox's fast drop-in/drop-out behavior.

LAYER 3 — DIMENSION META-SYSTEM

Each Rift belongs to a dimension.

A dimension is NOT merely:

"the kitchen map"
"the city map"
"the forest map"

A dimension must define its own gameplay grammar.

Every dimension should answer:

What physical law is strange here?

What can the player do here that they cannot do elsewhere?

How does carrying an artifact become harder?

What does the dimension itself do to the artifact?

What becomes more dangerous over time?

What cooperative opportunities exist?

What visual language immediately identifies the dimension?

What stories will naturally emerge?

---

# 2. WORLD SCALE

Roblox avatar scale and traversal speed must drive map dimensions.

Assume standard Roblox movement approximately equivalent to:

WalkSpeed ≈ 16 studs/sec

Do not create distances arbitrarily.

Every meaningful distance should correspond to desired traversal time.

General targets:

very short interaction distance:
8–20 studs

small room:
32–64 studs

standard gameplay room:
64–128 studs

large encounter room:
128–192 studs

major landmark area:
192–320 studs

corridor / connector:
30–100 studs

distance between interesting interactions:
generally no more than 5–12 seconds of normal movement unless the traversal itself is gameplay

Do not create long empty 300+ stud hallways.

Players should repeatedly encounter:

decisions
objects
visual discoveries
hazards
routes
collectibles
social opportunities

---

# 3. AVATAR-BASED DIMENSION STANDARDS

Design the modular kit around Roblox avatar readability.

General traversal widths:

solo corridor:
minimum approximately 10–12 studs

comfortable corridor:
14–18 studs

cooperative carrying corridor:
18–24+ studs

major hallway:
24–36 studs

Large artifacts may require larger passages.

Doorways:

standard:
approximately 10–14 studs wide
approximately 14–20 studs tall

heavy-object doors:
16–24+ studs wide

Do not create overly realistic human-sized architecture.

This game should have slightly exaggerated proportions.

Ceiling ranges:

small:
16–22 studs

standard:
22–32 studs

dramatic:
32–60 studs

Huge environments can exceed this when scale is part of the fantasy.

Avoid environments where the camera constantly collides with ceilings.

---

# 4. MODULAR GRID

Environment assets should generally obey an 8-stud construction grid.

Major room dimensions should preferably be clean multiples of:

8
16
32

Examples:

64 × 64

96 × 96

128 × 128

160 × 128

192 × 192

Do not force decorative objects to the grid, but structural architecture should align cleanly.

This makes:

procedural generation
room snapping
collision checking
portal connections
level editing
future expansion

far easier.

---

# 5. ROOM SOCKET STANDARD

Every modular room must contain standardized connection sockets.

Example concept:

Room Model
    Geometry
    Collision
    Decoration
    Sockets
        Socket_North
        Socket_South
        Socket_East
        Socket_West
    SpawnPoints
    ArtifactPoints
    HazardPoints
    LandmarkPoints

Sockets must use consistent orientation.

A socket should contain Attributes similar to:

SocketType
WidthClass
HeightClass
Direction
AllowedConnections
DoorStyle
OneWay
DifficultyTag

Possible SocketTypes:

Standard
Large
Vent
Vertical
Drop
Lift
Portal
Secret
Coop

Room assembly should connect compatible socket types.

Do not hardcode relationships through object names when Attributes or tags are more appropriate.

---

# 6. RIFT INSTANCE ARCHITECTURE

Do NOT generate all dimensions permanently into Workspace.

Instead:

Templates should live inside ServerStorage.

Example:

ServerStorage
    RiftTemplates
        GiantsKitchen
            Rooms
            Props
            Hazards
            ArtifactVisuals
        MoonAquarium
        ToyboxCatastrophe
        UpsideDownCity

Runtime maps should be cloned into Workspace only when necessary.

Suggested runtime structure:

Workspace
    Hub
    Museums
    RiftRuntime
        Rift_XXXXXXXX
            Geometry
            Gameplay
            Artifacts
            Hazards
            Players
            Effects

Every active Rift must have a unique RiftId.

Everything belonging to that Rift should be tagged or otherwise traceable back to RiftId.

This allows:

cleanup
debugging
analytics
server validation
memory tracking

---

# 7. RIFT CELLS

For V1, avoid teleporting players into separate Roblox Places for normal 2–5 minute expeditions.

Teleport latency would damage the core loop.

Instead maintain multiple isolated Rift Cells inside the same Place.

Think of them as temporary invisible stage containers.

Example:

Hub near world origin.

Then several Rift cells positioned at controlled offsets.

Example conceptual layout:

CELL A:
X +1500

CELL B:
X -1500

CELL C:
Z +1500

CELL D:
Z -1500

Additional cells may use combinations such as:

+1500, +1500

-1500, +1500

etc.

However:

DO NOT endlessly spread maps tens of thousands of studs away.

Keep normal active gameplay reasonably close to the world origin.

Prefer fewer reusable Rift cells with clean allocation over arbitrarily distant dimensions.

Create:

RiftCellAllocator

Responsibilities:

reserve cell
generate Rift
assign party
track occupants
cleanup Rift
reset cell
return cell to pool

Never allow two Rift instances to occupy the same cell simultaneously.

---

# 8. OPTIONAL FUTURE PLACE ARCHITECTURE

Design RiftService abstractions so a future Rift could exist in:

MODE A:
same-place Rift Cell

MODE B:
separate Roblox Place

without rewriting the entire gameplay system.

Normal runs should remain same-place initially.

Potential future separate Places could include:

massive raids
story dimensions
special seasonal worlds
very large multiplayer events

Do not implement unnecessary cross-place complexity in V1.

Simply architect the interfaces cleanly.

---

# 9. RIFT GENERATION MODEL

Use SEMI-PROCEDURAL generation.

Do NOT generate random primitive geometry.

Handcrafted rooms should be combined procedurally.

This produces higher art quality while preserving replayability.

The generation pipeline should conceptually be:

1. Receive DimensionId
2. Receive difficulty
3. Create deterministic server seed
4. Select Rift archetype
5. Generate room graph
6. Select compatible room templates
7. Connect sockets
8. Validate overlaps
9. Validate navigation
10. Place artifacts
11. Place optional areas
12. Place hazards
13. Apply Dimension modifiers
14. Generate extraction area
15. Perform validation pass
16. Spawn environment
17. Enable Rift
18. Allow players to enter

The server owns the seed.

Use deterministic Random objects where appropriate.

Record the seed in analytics/debug information.

Example:

RiftId
DimensionId
Seed
Difficulty
PartyId
GenerationVersion

This makes failed maps reproducible.

---

# 10. ROOM GRAPH GENERATION

Generate a gameplay graph before generating geometry.

The graph is more important than random room placement.

Example simple Rift:

ENTRY
  |
A
 / \
B   C
|   |
D   OPTIONAL
 \ /
CORE
 |
EXTRACTION

Rifts should contain:

main route

optional risk branches

rare rooms

shortcut opportunities

artifact areas

event spaces

extraction route

Avoid purely linear corridors.

Avoid giant confusing mazes.

The player should sometimes think:

"Do we risk going into that side room?"

rather than:

"Where are we supposed to go?"

---

# 11. TARGET RIFT SIZE

For normal 2–5 minute Rifts:

rough target:

5–10 meaningful rooms

Total expected path length:

approximately 450–900 studs

depending on traversal mechanics.

Do not measure difficulty solely using distance.

Difficulty should come primarily from:

environment rules
hazards
artifact transportation
timing
route choices
group coordination

---

# 12. RIFT PACING CURVE

Every Rift should have a tension curve.

Use approximately:

0–15%:
ORIENTATION

The player enters.

Threat is low.

Dimension rule is introduced visually.

15–45%:
EXPLORATION

Players search.

Artifacts discovered.

Routes branch.

45–70%:
GREED PHASE

Players decide whether to:

extract what they have

or

go deeper for better artifacts.

70–90%:
INSTABILITY

Dimension becomes dangerous.

More hazards.

Environmental changes.

Routes may shift.

90–100%:
ESCAPE

Strong audiovisual escalation.

Players sprint/carry/fight toward extraction.

The final section should often feel significantly more intense than entry.

---

# 13. RIFT INSTABILITY SYSTEM

Create a global concept:

RIFT INSTABILITY

Each Rift instance has:

InstabilityLevel

Potential range:

0–100

The exact UI representation may change.

Instability increases through combinations of:

time

valuable artifact interaction

dimension-specific events

player actions

optional greed mechanics

Instability should alter the WORLD.

Not merely increase enemy damage.

Examples:

walls begin moving

gravity pulses

flood level rises

lights fail

objects start floating

rooms rotate

paths collapse

creatures become active

portals become unstable

artifact behaviour changes

This makes the dimension itself feel alive.

---

# 14. EXTRACTION

Extraction should be spatially and visually obvious.

Do not make players search for a tiny UI marker.

Extraction should be represented by something memorable:

large portal
containment elevator
rift stabilizer
research gateway
dimensional gate

When instability begins escalating heavily:

the extraction location should become recognizable through:

lighting
sound
world-space beacon
environmental effects

A major design question per Rift should be:

"How does getting OUT differ from getting IN?"

Examples:

same path becomes dangerous

new shortcut opens

gravity changes

map begins collapsing

water level changes

rooms rotate

enemies wake

This transforms retreat into gameplay.

---

# 15. PORTAL TRANSITION

Entering a Rift should feel magical but fast.

Avoid conventional loading screens whenever possible.

Desired sequence:

player approaches portal

portal surface reacts

camera/audio distort slightly

player crosses threshold

brief transition volume

Rift environment appears

Total perceived interruption should be minimal.

Possible transition masking:

bright flash

tunnel effect

screen-space distortion

temporary particle volume

audio low-pass effect

camera FOV shift

Use the transition to allow streaming/generation to finish.

Pre-generate Rift before the player physically enters whenever possible.

---

# 16. THE DIMENSION DESIGN BIBLE

Every dimension must have a DimensionDefinition.

Conceptual schema:

DimensionId

DisplayName

FantasySentence

CorePhysicalRule

SecondaryRule

TraversalModifier

PrimaryHazard

SecondaryHazards

ArtifactBehaviourBias

MutationBias

InstabilityBehaviour

ExtractionBehaviour

ColorPalette

LightingProfile

AudioProfile

RoomSet

PropSet

CreatureSet

RarityWeights

DifficultyRange

CoopMechanic

SignatureLandmark

SecretRules

A new dimension should be largely addable through data + modular content instead of rewriting RiftService.

---

# 17. CRITICAL RULE

A new Rift should NEVER qualify as a full dimension merely because:

textures changed

colors changed

props changed

The player's behaviour must change.

Example:

BAD:

Kitchen Dimension:
normal Roblox movement but everything looks like a kitchen.

GOOD:

Giant's Kitchen:

Players are tiny.

Ordinary objects become terrain.

Liquids become hazards.

Appliances become machines.

Heavy artifacts interact with slopes.

Falling utensils behave like environmental hazards.

Certain objects can only be moved when multiple players coordinate.

That is a dimension.

---

# 18. LAUNCH DIMENSION 1
# GIANT'S KITCHEN

Fantasy:

"You are tiny inside a kitchen where every normal household object is now enormous."

CORE RULE:

SCALE.

The player is tiny relative to the environment.

Gameplay opportunities:

climb drawers

cross utensils

ride moving appliances

jump across plates

navigate countertops

avoid spilled liquids

move through cabinets

use giant household objects as traversal elements

Signature hazards:

falling utensils

boiling water

moving appliances

rolling fruit

spilled liquid

closing drawers

toaster mechanisms

Artifact examples:

haunted fridge magnet

living cereal box

tiny golden refrigerator

impossible spoon

floating toaster

screaming kettle

sentient mug

forbidden cookbook

Signature artifact behaviour:

many objects are awkwardly shaped or heavy.

Instability:

the kitchen begins physically coming alive.

Cabinets open.

Appliances activate.

Objects fall.

Water spills.

Floor geometry becomes dangerous.

Extraction:

portal begins forming somewhere visually accessible but difficult to reach as the environment collapses.

Gameplay tone:

chaotic

funny

toyetic

high-energy

NOT horror.

---

# 19. LAUNCH DIMENSION 2
# MOON AQUARIUM

Fantasy:

"An impossible aquarium floating in space where water exists in enormous suspended bubbles."

CORE RULE:

WATER + LOW GRAVITY.

This dimension should immediately feel different from the kitchen.

Environment:

glass platforms

floating islands

huge water spheres

stars visible outside

suspended aquariums

broken research stations

floating coral

strange fish

Movement:

normal gravity in some areas

low gravity in others

water bubbles allow swimming through open space

Players can leap between floating structures.

Artifacts may float away.

Signature gameplay:

physically pulling floating artifacts toward safe ground.

Co-op possibility:

one player anchors another using equipment.

Hazards:

water bubbles move

predatory creatures

oxygenless zones

glass fractures

gravity reversals

currents

floating debris

Signature artifacts:

living moon rock

reverse fishbowl

miniature black hole

cosmic jellyfish

floating anchor

star fragment

singing coral

Instability:

gravity becomes increasingly inconsistent.

Water bubbles burst or move.

Platforms drift apart.

Objects begin orbiting strange gravitational points.

Extraction:

portal becomes suspended in open space.

Players may need to launch toward it.

Visual palette:

deep navy

cyan

violet

silver

bioluminescent accents

---

# 20. LAUNCH DIMENSION 3
# TOYBOX CATASTROPHE

Fantasy:

"You are inside an enormous toy world that is gradually turning itself on."

CORE RULE:

MOVING MECHANISMS.

Environment:

building blocks

toy trains

plastic castles

board games

mechanical toys

giant race tracks

action figure environments

Traversal:

moving platforms

conveyor tracks

toy cars

launchers

wind-up mechanisms

Signature hazards:

toy trains

giant spinning tops

mechanical claws

spring-loaded objects

falling blocks

Artifact examples:

cursed rubber duck

living action figure

infinite yo-yo

golden building block

wind-up moon

sentient toy train

Instability:

everything begins activating simultaneously.

The map itself becomes a machine.

Extraction:

players must navigate through increasingly fast-moving mechanisms.

Tone:

bright

nostalgic

fun

dangerous without becoming frightening.

---

# 21. FUTURE DIMENSION
# UPSIDE-DOWN CITY

Fantasy:

"A broken city where gravity chooses different directions depending on the surface."

CORE RULE:

DIRECTIONAL GRAVITY.

Rooms may have:

wall gravity

ceiling gravity

rotating gravity

temporary zero gravity

Important:

Do NOT implement unreliable physics hacks simply for spectacle.

Build predictable gravity volumes.

Communicate them visually.

Possible colors/particles should indicate gravity direction.

Artifacts:

inverted traffic light

floating taxi sign

impossible streetlamp

upside-down mailbox

gravity cube

Instability:

gravity fields begin shifting more frequently.

Extraction may require navigating between multiple gravity orientations.

---

# 22. FUTURE DIMENSION
# ENDLESS SUPERMARKET

Fantasy:

"A supermarket that reorganizes itself every time nobody is looking."

CORE RULE:

LAYOUT INSTABILITY.

Aisles change.

Shelves move.

Doors appear.

Sections rotate.

Players gradually learn visual landmarks.

Artifacts:

infinite cereal

living shopping cart

forbidden coupon

self-restocking shelf

golden barcode

hazards:

moving shelving

cleaning machines

freezer rooms

closing security doors

Instantiation:

the supermarket should procedurally rearrange sections while preserving a valid route.

Instability:

layout changes become increasingly aggressive.

Extraction location may stay fixed while pathfinding changes.

---

# 23. FUTURE DIMENSION
# LIVING MUSEUM

Fantasy:

"A museum containing artifacts that do not want to stay exhibits."

CORE RULE:

OBJECT UNCERTAINTY.

Some artifacts are genuine.

Some are creatures.

Some environmental props react when nobody is looking.

Gameplay should involve observation.

Players should gradually learn tells.

Artifacts may:

move

hide

attack

imitate props

follow players

Trade certainty for curiosity.

Instability:

more exhibits awaken.

Eventually the museum becomes chaotic.

---

# 24. FUTURE DIMENSION
# FORGOTTEN INTERNET

Fantasy:

"A physicalized abandoned digital world built from the remains of an old internet."

Avoid direct copyrighted website recreation.

Instead use original surreal digital architecture.

CORE RULE:

LOGIC GLITCHES.

Examples:

doors lead to different locations

platforms briefly duplicate

gravity skips

geometry unloads/reloads visually

fake pathways

artifact states change

Visual identity:

old UI shapes

pixel fragments

broken geometry

CRT-inspired effects

digital voids

Avoid excessive screen distortion that could cause discomfort.

---

# 25. DIMENSIONAL CONSISTENCY

Despite major differences, all dimensions must share common game language.

Players should always understand:

how to pick up

how to carry

how to drop

how to inspect

how to extract

what danger cues mean

where extraction roughly is

what counts as an artifact

The WORLD changes.

The control language does not.

---

# 26. ART DIRECTION

The environments should look like actual Roblox environments.

Avoid hyperreal AI-looking worlds.

Desired direction:

clean geometry

strong silhouettes

slightly exaggerated proportions

controlled stylization

readable materials

simple but polished textures

good lighting

careful color blocking

limited micro-detail

toyetic shapes

Roblox-native character scale

Reference philosophy:

high-end Roblox game art

NOT Pixar imitation

NOT photoreal Unreal Engine

NOT generic AI fantasy render

NOT endless neon simulator design

Environment assets must remain readable on:

mobile

tablet

desktop

---

# 27. VISUAL READABILITY

Gameplay objects need visual hierarchy.

Examples:

interactive artifact:
distinct silhouette + subtle highlight language

hazard:
consistent warning language

safe route:
natural environment composition

secret:
recognizable but understated clue language

portal:
very strong silhouette

Do not cover the entire environment in glowing outlines.

Use effects intentionally.

---

# 28. LANDMARKS

Every Rift should contain one memorable landmark.

Examples:

Giant's Kitchen:
massive refrigerator

Moon Aquarium:
broken orbital aquarium dome

Toybox:
giant toy castle / train loop

Supermarket:
central checkout tower

Upside-Down City:
floating skyscraper intersection

Landmarks serve:

navigation

visual identity

screenshots

marketing

orientation

---

# 29. PLAYER NAVIGATION

Avoid minimap dependency.

The environment should naturally teach navigation using:

lighting

color

landmarks

architecture

sound

portal beams

Use UI markers only when necessary.

Players should rarely feel lost.

Confusion is not difficulty.

---

# 30. ARTIFACT PLACEMENT

Do not simply randomize artifact coordinates.

Use curated ArtifactSpawnPoints.

Spawn point Attributes could include:

SizeClass
RarityRange
AllowedCategories
CarryDifficulty
RequiresCoop
HazardAssociation
VisibilityClass

This ensures:

giant artifacts don't spawn in tiny closets

rare artifacts appear in interesting spaces

carry paths remain valid

---

# 31. CARRY PATH VALIDATION

Map generation must account for the size of artifacts.

A route valid for an avatar may be impossible while carrying a refrigerator-sized object.

Generation should reason about:

player width

artifact width

artifact height

turning radius

doors

stairs

ladders

vertical gaps

For large artifacts:

ensure at least one valid extraction path.

Optional shortcuts may remain inaccessible.

---

# 32. COLLISION

Decorative complexity must NOT equal collision complexity.

Use simplified collision proxies where necessary.

Many decorative objects should be CanCollide = false.

Avoid Mesh collision modes that create unpredictable movement when simple Box/Hull collision is sufficient.

Critical gameplay surfaces require predictable collision.

No tiny decorative lips that stop carried objects.

No stairs that constantly snag physics objects.

Test carrying through every structural kit piece.

---

# 33. HEAVY ARTIFACT DESIGN

Large artifacts are central to emergent gameplay.

Create size categories:

HANDHELD

MEDIUM

HEAVY

HUGE

COOPERATIVE

Each size affects:

movement

animation

camera

door requirements

turning

equipment requirements

Hazards become interesting partly because the player is trying to move awkward cargo through them.

---

# 34. MUSEUM / HUB MAP

The hub should be much simpler than Rifts.

The Hub is a psychological reset point.

It should communicate:

safety

ownership

social activity

aspiration

Primary hub components:

spawn area

central Rift portal complex

museum access

party area

research/progression station

collection book access

social viewing areas

event visualization

The portal should dominate the main composition.

A new player should instinctively walk toward it.

---

# 35. HUB SCALE

Target approximately:

500–800 studs usable diameter

but do not fill this entire region with content simply because space exists.

Core traversal between:

spawn

portal

museum

progression

should generally remain short.

Aim for major Hub functions within approximately 10–20 seconds of one another.

Do not create realistic city-scale travel.

The Hub is navigation infrastructure, not the main exploration content.

---

# 36. MUSEUM SPATIAL MODEL

Do not necessarily place fifty enormous player museums permanently around the physical Hub.

Evaluate alternatives.

Recommended approach:

each player museum exists as an instanced/personalized space accessed from hub.

Possible V1 implementation:

museum cells located in reusable areas

or

shared gallery architecture using allocated plots

The architecture must allow:

player ownership

visitors

artifact placement

layout persistence

performance limits

Do not allow unlimited physics-enabled museum artifacts.

Museum artifact behavior should use distance-based simulation.

---

# 37. STREAMING

Use StreamingEnabled.

Design maps around streaming rather than fighting it.

The portal transition provides an opportunity to pre-stream the Rift.

Before teleporting/transitioning player into Rift:

generate environment

request relevant streaming where appropriate

ensure starting room exists

verify gameplay-critical geometry is available

Avoid requiring entire Rift to load before beginning.

Use progressive spatial loading.

---

# 38. PERFORMANCE BUDGET

Design every Rift for mobile.

Avoid:

thousands of active physics objects

huge particle counts

unbounded AI

unnecessary transparent geometry

expensive lights everywhere

high-poly decorative clutter

excessive textures

Every room should have a rough complexity budget.

Create debugging statistics for:

instance count

BasePart count

active physics assemblies

particle emitters

lights

NPC count

artifact count

memory-relevant assets

Network traffic must also be monitored.

---

# 39. PHYSICS ACTIVATION

Do not simulate every interactive prop constantly.

Props should generally be:

static

or

sleeping

until interaction becomes relevant.

Activate physics based on:

player proximity

hazard state

Rift instability

artifact interaction

Deactivate or clean up unnecessary objects.

---

# 40. NETWORK AUTHORITY

The server determines:

Rift generation

Rift seed

artifact spawn

artifact identity

artifact rarity

artifact mutation

extraction success

hazard state

Rift instability

The client may handle:

cosmetic interpolation

camera

UI

local sound enhancement

non-authoritative VFX

Never let client claim:

"I extracted this Legendary artifact."

Server must validate:

RiftId

ArtifactInstanceId

ownership/carry state

player location

extraction zone

Rift state

---

# 41. CODE ARCHITECTURE

Create clean systems approximately along these lines:

ServerScriptService
    Systems
        RiftService
        RiftGenerator
        RiftCellAllocator
        RiftLifecycleService
        RiftInstabilityService
        RiftArtifactService
        RiftHazardService
        ExtractionService

ReplicatedStorage
    Shared
        RiftDefinitions
        DimensionDefinitions
        RoomDefinitions
        ArtifactDefinitions
        RiftTypes
        RiftConstants

ServerStorage
    RiftTemplates
        GiantsKitchen
        MoonAquarium
        ToyboxCatastrophe

Workspace
    Hub
    RiftRuntime
    MuseumRuntime

Naming may change if a superior project architecture already exists.

Before introducing a parallel architecture:

AUDIT THE EXISTING PROJECT.

Reuse good systems.

Do not duplicate services unnecessarily.

---

# 42. COLLECTIONSERVICE TAGS

Consider standardized tags such as:

RiftSocket

ArtifactSpawn

HazardSpawn

PlayerSpawn

ExtractionPoint

Landmark

SecretPoint

TraversalAnchor

CoopAnchor

RoomBounds

Use Attributes for metadata.

Do not abuse ValueObjects when Attributes provide a cleaner solution.

---

# 43. MAP VALIDATION

Every generated Rift must run automated validation.

Validation should check:

entry exists

extraction exists

main path exists

room count within bounds

no impossible overlaps

critical sockets connected

artifact count within allowed range

large artifact route exists

required landmark exists

spawn zones valid

hazards do not cover entry

extraction is reachable

Generation should fail safely.

If validation fails:

destroy map

retry with another generation seed or configuration

Do NOT send players into invalid generated worlds.

---

# 44. DEBUG MODE

Build developer debugging features.

Examples:

/rift generate GiantsKitchen

/rift generate MoonAquarium seed=12345

/rift instability 80

/rift cleanup

/rift teleport room=5

Show:

RoomId

RiftId

Seed

socket links

room bounds

artifact spawn locations

main path

optional routes

generation duration

This is critical.

Procedural-generation systems become extremely difficult to debug without visualization.

---

# 45. GENERATION PERFORMANCE

Map generation should occur rapidly.

Do not stall the server main thread with unnecessary work.

Where practical:

construct graph

select templates

calculate transforms

then instantiate.

Measure:

generation milliseconds

instance creation cost

streaming delay

Time from player requesting Rift to portal readiness should feel extremely short.

---

# 46. BUILD PROCESS

DO NOT immediately build all dimensions.

Implementation phases:

PHASE 1

Build:

RiftCellAllocator

room socket specification

RoomDefinition format

basic RiftGenerator

entry room

3–5 room templates

extraction room

basic validation

No fancy art required.

Prove generation.

PHASE 2

Build one polished dimension:

GIANT'S KITCHEN.

Approximately:

6–10 modular room templates

several connectors

1 major landmark

basic hazards

artifact spawn system

instability escalation

extraction

PHASE 3

Playtest.

Test specifically:

Is navigation obvious?

Are rooms too large?

Are carried objects getting stuck?

Does extraction feel exciting?

Does procedural generation create boring layouts?

Does the player experience meaningful decisions?

PHASE 4

Build second dimension:

MOON AQUARIUM.

The purpose is to prove DimensionDefinition genuinely supports different world rules.

If adding Moon Aquarium requires rewriting most of RiftGenerator:

architecture is insufficiently modular.

PHASE 5

Build Toybox.

Only then begin expanding the full dimension library.

---

# 47. GAME DIRECTION TEST

Whenever designing a Rift, ask:

"If I removed the textures and models, would this Rift still PLAY differently?"

If NO:

the dimension concept is too shallow.

Example:

Giant's Kitchen:
scale + physical household hazards

Moon Aquarium:
floating water + low gravity

Toybox:
mechanical moving environment

Upside-Down City:
directional gravity

Supermarket:
shifting topology

Living Museum:
uncertain artifact identity

Each changes player behavior.

---

# 48. STORY EMERGENCE TEST

A Rift should produce statements like:

"We found a gigantic floating fish but it kept escaping upward."

"We had to carry the fridge together while the kitchen flooded."

"The aisle moved and separated us."

"The gravity changed while I was carrying the artifact."

"The statue we were trying to extract suddenly woke up."

Those are good experiences.

"We collected +847 currency."

That alone is not sufficient.

---

# 49. SCREENSHOT TEST

At least one area of every dimension should produce strong screenshots.

Ask:

Would somebody scrolling TikTok/YouTube/Roblox immediately understand that something bizarre is happening?

Use:

scale

color

landmarks

strange artifact silhouettes

unexpected physics

group interaction

Do not depend on UI to make the scene interesting.

---

# 50. ACCEPTANCE CRITERIA

The initial Rift/world architecture is acceptable when:

A Rift can be generated from a deterministic seed.

Rooms connect through standardized sockets.

Generation produces no obvious overlaps.

The server can maintain multiple isolated Rift instances.

Rifts clean themselves completely after ending.

Entry/extraction are always reachable.

Large artifacts have valid carry paths.

Dimension rules are data-driven where practical.

The first dimension can be added without hardcoding every behavior inside RiftService.

The second dimension can substantially change physics/gameplay without rewriting the architecture.

Streaming works.

Mobile performance remains acceptable.

Server authority protects valuable artifacts.

A developer can reproduce a Rift from its seed.

A designer can add a room template without changing RiftGenerator code.

A designer can add artifact spawn locations visually in Studio.

Debug visualization exists.

---

# 51. YOUR FIRST ACTIONS

Before changing code:

1. Inspect the repository.
2. Identify current Roblox project architecture.
3. Identify existing map/world systems.
4. Identify any Rift-related code already present.
5. Identify framework/library conventions.
6. Identify networking architecture.
7. Identify data architecture.
8. Identify naming conventions.
9. Identify whether StreamingEnabled/configuration exists.
10. Identify what should be reused.

Then produce:

WORLD_ARCHITECTURE_AUDIT.md

Include:

existing relevant architecture

systems that can be reused

technical risks

conflicts with this specification

recommended implementation sequence

proposed file structure

proposed room format

proposed DimensionDefinition schema

proposed RiftDefinition schema

Only after the audit:

implement Phase 1.

Do not jump directly to giant polished maps.

Engineering foundations first.

---

# 52. FINAL DESIGN PRINCIPLE

GRAB THE WEIRD should feel as though every portal leads somewhere governed by a different impossible idea.

Rifts should not feel like levels.

They should feel like DIFFERENT REALITIES.

A player should eventually see the portal change color, shape, sound or behavior and think:

"Oh no, that's Moon Aquarium."

or:

"YES, Giant's Kitchen."

That emotional recognition is the goal.

Each dimension needs:

a fantasy

a rule

a risk

a traversal identity

an artifact identity

an instability identity

an extraction identity

a strong visual identity

and at least one mechanic capable of producing unexpected social stories.

Build the map architecture around those principles.