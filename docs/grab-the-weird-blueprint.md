# GRAB THE WEIRD! — Roblox Master Development Blueprint

> Project codename: **PROJECT ODDVAULT**
>
> Working title: **GRAB THE WEIRD!**

You are the lead game director, gameplay engineer, systems designer, economy designer, UX designer, technical architect and LiveOps designer for a commercial Roblox project currently codenamed **PROJECT ODDVAULT**, working title **GRAB THE WEIRD!**

Your objective is not merely to produce a functional Roblox game.

Your objective is to design, engineer and continuously refine a Roblox experience capable of achieving mass organic distribution, high daily retention, strong intentional co-play, sustainable monetization and long-term franchise potential.

The experience must be immediately understandable to a young/new Roblox player while containing enough emergent interaction, collection depth, mastery, social identity and LiveOps extensibility to remain compelling for experienced players.

Do not create a generic simulator.

Do not create a direct clone of Steal An Egg, Grow a Garden, Steal a Brainrot, Adopt Me, Pet Simulator, Brookhaven or any other Roblox experience.

Extract structural lessons from successful Roblox design without copying their intellectual property, aesthetic identity, terminology, characters, worlds, interface, assets or exact mechanics.

The fundamental product thesis is:

**Simple action + uncertain situation + permanent ownership + visible social status + long-term mastery + continuous novelty.**

The emotional design objective is:

**Every session should have the possibility of generating a story the player wants to show another person.**

The game fantasy is:

**Players travel through unstable portals into bizarre worlds, physically recover impossible artifacts, escape before the world becomes too dangerous, and use what they recover to build an increasingly spectacular museum of impossible things.**

The central marketing sentence is:

**Jump through a portal. Grab something weird. Get it home alive.**

Everything in the project must reinforce this fantasy.

---

## PRODUCT PRINCIPLES

Design the experience around competence, autonomy and relatedness.

Competence must come from improved knowledge, traversal skill, extraction decisions, equipment use and increasingly difficult expeditions.

Autonomy must come from artifact choices, museum design, loadouts, expedition selection, display choices and personal expression.

Relatedness must come from meaningful multiplayer interaction such as carrying heavy objects together, reviving allies, cooperative puzzles, visiting museums, trading and shared expedition accomplishments.

Do not use frustration as the primary monetization engine.

Do not intentionally manufacture compulsive behaviour through fake scarcity, deceptive timers, streak destruction, paid near-miss systems or gambling-style monetization.

Randomness may create excitement during gameplay but paid randomness should not be foundational.

A missed day must not destroy a player's accumulated progress.

Permanent player possessions should be respected.

The player must never need to sacrifice a beloved collection simply to access a prestige multiplier.

---

## CORE LOOP

Implement the primary loop:

**EXPLORE → DISCOVER → CARRY → SURVIVE → EXTRACT → DISPLAY → EARN → UPGRADE → EXPLORE.**

Minute-to-minute gameplay must focus on movement, observation, environmental interaction, physical object manipulation and cooperative traversal.

The player enters a Rift.

The player discovers artifacts.

Artifacts physically exist in the world.

The player must transport them.

Different artifacts have different mass, physical behaviour, instability and interaction characteristics.

Environmental hazards progressively increase.

The player reaches extraction.

Successfully extracted artifacts become permanent player possessions.

The player returns to their museum.

Artifacts can be displayed.

Displays increase museum reputation and generate a controlled amount of passive visitor revenue.

Revenue is reinvested in museum expansion, expedition equipment and new exploration capabilities.

Better capabilities open harder Rifts.

Harder Rifts expose increasingly unusual collectibles and challenges.

---

## FIRST-TIME USER EXPERIENCE

The game must be playable before it is explainable.

Avoid a conventional tutorial sequence.

A completely new user should spawn with their camera naturally facing the central portal.

Within approximately five seconds, communicate one instruction visually:

**GRAB SOMETHING WEIRD AND BRING IT BACK.**

Use environmental composition, animation, directional motion, lighting and extremely short contextual prompts.

Do not display walls of text.

Target the following FTUE:

### 0–10 seconds
Player understands that the portal is the destination.

### 10–20 seconds
Player enters first Rift.

### 20–40 seconds
Player encounters obvious interactable artifact.

### 40–60 seconds
Player picks artifact up and sees immediate physical/audiovisual response.

### 45–90 seconds
Environmental tension begins.

### Approximately 60–120 seconds
Player successfully extracts first artifact.

### Immediately after
Deliver a strong celebratory response.

Artifact appears in the player's museum.

Visitor/reputation/currency response occurs.

First museum improvement becomes affordable quickly.

Within the first several minutes:

- Expose collection book silhouettes.
- Show another player's visibly superior or unusual museum/artifact.
- Show a future destination the player cannot yet access.

The player should leave onboarding understanding the current loop and wanting something they do not yet possess.

---

## ARTIFACT ARCHITECTURE

Artifacts are the heart of the game.

Do not implement artifacts as static numerical inventory entries.

Each artifact should be describable by data including:

- ArtifactId
- DisplayName
- BaseForm
- Rarity
- WorldOrigin
- WeightClass
- CarryProfile
- BehaviourProfile
- ValueProfile
- MuseumAppeal
- MutationCompatibility
- InteractionTags
- AudioProfile
- VFXProfile
- AnimationProfile
- LoreFragment
- TradeRules
- CollectionCategory

Support rarity tiers approximately equivalent to:

- Common
- Odd
- Bizarre
- Impossible
- Forbidden

Names may change during art direction.

Support mutations through a compositional system rather than unique code for every combination.

Example mutations:

- Frozen
- Overgrown
- Golden
- Glitched
- Celestial
- Haunted
- Inverted
- Miniature
- Gigantic
- Radioactive
- Dreaming
- Mechanical
- Unstable

Mutation composition must be data-driven.

A mutation may change:

- appearance
- particle systems
- sound
- value
- museum appeal
- mass
- physics behaviour
- interaction behaviour
- rarity
- environmental reactions

Avoid exponential numerical inflation becoming the only reason mutations matter.

Prefer perceptible behavioural differences.

An Inverted artifact may resist gravity.

A Haunted artifact may occasionally move inside the museum.

A Gigantic artifact may require multiple players to transport.

A Glitched artifact may periodically change physical state.

A Frozen artifact may slide.

A Living artifact may attempt to escape.

The objective is for collectibles to produce stories.

---

## PROCEDURAL RIFT SYSTEM

Create an extensible Rift framework.

A Rift consists of:

- Theme
- RoomPool
- SpawnRules
- ArtifactPool
- Hazards
- EnemyOrCreaturePool
- TraversalRules
- EnvironmentalModifiers
- AudioProfile
- LightingProfile
- DifficultyProfile
- ExtractionRules
- SpecialEvents

Individual worlds should be assembled using modular rooms/areas rather than completely procedural geometry when handcrafted composition produces better results.

Initial world concepts may include:

- Toybox Catastrophe
- Upside Down City
- Endless Supermarket
- Moon Aquarium
- Living Museum
- Candy Factory
- Forgotten Internet
- Giant's Kitchen
- Dream Forest
- The Back Room

Each Rift must have at least one gameplay distinction rather than merely a visual skin.

Examples:

- altered gravity
- scale differences
- moving walls
- water physics
- visibility changes
- conveyor systems
- unstable floors
- wandering threats
- object-specific puzzles
- increasing environmental instability

Players should gradually learn the rules of each Rift.

Knowledge itself should become progression.

---

## EXPEDITION STRUCTURE

Standard expeditions should generally be short enough to support Roblox's drop-in/drop-out culture.

Target a baseline **2–5 minute expedition**.

Do not require thirty minutes before a player feels accomplishment.

Longer high-level expeditions may exist later.

Every expedition needs:

- an immediate objective
- optional greed/risk decisions
- rising tension
- clear extraction
- a satisfying ending

Use risk/reward through optional behaviour.

Players may leave early with modest loot.

Players who remain longer encounter stronger opportunities and greater danger.

Never arbitrarily delete existing permanent collection progress because a player failed a run.

Only unextracted expedition loot should normally be at risk.

---

## PHYSICAL CARRYING

Physical carrying should be one of the signature mechanics.

Artifact mass affects movement.

Small artifacts may be carried with minimal penalty.

Large artifacts reduce mobility.

Huge artifacts may require a cart.

Enormous artifacts may require two or more players.

Some artifacts alter carrying mechanics.

Examples:

- floats upward
- rolls
- pulls toward metallic objects
- runs away
- temporarily becomes heavier
- attracts enemies
- makes noise
- changes gravity nearby
- obscures vision
- randomly expands and contracts

Physics should create comedy and emergent multiplayer scenarios without feeling uncontrollable.

Network ownership and authoritative validation must be designed securely.

Never allow a client to authoritatively declare successful extraction, artifact identity, mutation, currency reward or inventory ownership.

---

## PLAYER MUSEUM

Every player receives a persistent personal museum.

The museum serves simultaneously as:

- home
- collection display
- social identity
- progress visualization
- passive economy
- customization surface
- social destination

Museum progression should visibly transform the world.

Do not rely only on menu-based upgrades.

Example progression:

- Temporary garage
- Curiosity shop
- Small museum
- Research museum
- Anomaly institute
- Impossible museum

Museum size, architecture and display technology evolve.

Allow substantial customization while keeping layouts performant.

Players should be able to save museum layouts.

Other players can visit.

Artifacts should remain interactive in museums when performance permits.

Museum popularity/reputation should reflect collection diversity, rarity, arrangement and achievements rather than simply total currency spent.

---

## COLLECTION BOOK

Create an elegant collection system.

Undiscovered entries may appear as silhouettes, hints or incomplete descriptions.

Use curiosity carefully.

Example clue:

> “Only appears when gravity fails in the Toybox.”

Do not reveal every secret immediately.

Collection categories may include:

- World
- Form
- Rarity
- Mutation
- Behaviour
- Event
- Secret

Track meaningful completion milestones.

Completion rewards should primarily be cosmetic, architectural or exploratory rather than destructive power inflation.

---

## SOCIAL DESIGN

Multiplayer interaction is a first-class requirement.

Create mechanics that are mechanically easier or more interesting with other people.

Potential systems:

- cooperative heavy carrying
- revival
- shared traversal mechanics
- doors requiring multiple players
- group extraction
- museum visits
- reactions
- safe trading
- party expeditions
- cooperative event bosses/hazards
- group achievements
- team time trials

Do not force friend invitations through reward spam.

Friend participation should naturally improve the experience.

Support private servers where appropriate.

---

## OPTIONAL COMPETITIVE PLAY

Competition may exist without turning the entire experience hostile.

Possible modes:

- Rift racing
- artifact extraction speed records
- weekly challenge boards
- museum design showcases
- rare discovery announcements
- team challenge expeditions

Avoid allowing unrestricted griefing to destroy another player's permanent museum or prized collection.

If theft mechanics are explored, prototype safer alternatives such as stealing temporary expedition objectives, copying/displaying replicas, opt-in competitive zones, or recoverable theft rather than irreversible loss.

Evaluate actual player sentiment before introducing permanent-loss PvP.

---

## PROGRESSION

Progress through capabilities rather than only arithmetic multipliers.

Equipment categories may include:

- scanner
- containment device
- cart
- grapple
- mobility tool
- hazard protection
- anti-gravity harness
- cooperative carrying rig
- artifact stabilizer
- portable extraction utility

Upgrades should open new decisions.

Example:

An anti-gravity harness allows recovery of floating artifacts from areas previously inaccessible.

A containment device allows transportation of aggressive artifacts.

A stronger cart allows heavy artifacts but reduces maneuverability.

Create meaningful loadout decisions.

Do not allow one linear best loadout to solve every situation.

---

## ECONOMY

Keep the economy understandable.

Avoid unnecessary currencies.

Prefer approximately:

- Primary earned currency
- Museum reputation/progression

A seasonal token may temporarily exist during specific events if needed.

Avoid five currencies whose purpose the player cannot explain.

Primary currency sinks:

- museum expansion
- equipment
- research
- display technology
- cosmetics purchasable through gameplay
- crafting/combination systems where appropriate

Monitor inflation continuously.

Offline income should reward ownership without making active gameplay irrelevant.

Place strict caps and diminishing returns on offline accumulation where needed.

Active expedition play must remain the fastest route toward interesting progress.

---

## TRADING

Trading can become a major retention system but also produces scams, exploits and economic instability.

Do not implement it casually.

Use an explicit two-stage confirmation system.

Display exact item names, mutation properties and rarity.

Prevent last-frame item swapping.

Lock both offers during final confirmation.

Log transaction IDs server-side.

Maintain trade histories.

Implement anti-dupe auditing.

Provide restrictions for newly acquired suspicious assets if required.

Consider trade eligibility progression so completely new accounts cannot immediately become mule accounts.

Do not expose paid-item trading to users when Roblox policy disallows it.

---

## DYNAMIC EVENTS

Build a data-driven modifier/event framework.

Example event:

**RIFT STORM**

A world temporarily receives one or more modifiers:

- GIANT
- HAUNTED
- ZERO GRAVITY
- GOLDEN
- ALIVE
- DOUBLE INSTABILITY
- MIRROR
- OVERGROWN
- GLITCHED

Events must visually alter the portal/hub.

Players should notice that something is happening without relying on a popup.

Avoid deceptive countdowns.

Most gameplay-affecting event content should recur.

Limited cosmetics may be used carefully, but do not weaponize FOMO.

---

## DAILY / WEEKLY ENGAGEMENT

Daily systems should redirect players toward interesting gameplay rather than demand repetitive chores.

Examples:

- Extract three Living artifacts.
- Recover an artifact with another player.
- Visit another museum.
- Survive an unstable Rift.
- Extract with less than ten seconds remaining.
- Discover a new mutation.
- Complete a run without dropping your artifact.

Missing a day should not reset a long streak.

Use accumulative or forgiving progression.

Weekly challenges should encourage varied systems and social play.

---

## LIVEOPS

Architect for continuous content production.

A designer should be able to add:

- new artifact
- new mutation
- new event
- new Rift
- new quest
- new museum decoration
- new reward

with minimal new code whenever possible.

Use configuration modules and reusable components.

Separate content data from systems logic.

Create a content validation tool/process capable of detecting:

- missing IDs
- duplicate IDs
- invalid rarity references
- broken mutation mappings
- missing assets
- missing thumbnails/icons
- invalid reward values

Treat content pipeline velocity as a major engineering requirement.

---

## MONETIZATION

Monetization must be layered onto enjoyment rather than repairing deliberately created frustration.

Preferred monetization categories:

- cosmetics
- museum themes
- display styles
- emotes
- carry animations
- portal visual effects
- player cosmetic equipment
- museum layout slots
- private server functionality
- UGC/avatar items
- subscription cosmetic bundle
- seasonal premium cosmetic reward track

Avoid pay-to-win advantages in competitive systems.

Do not sell permanent superiority.

Do not build the core economy around paid random outcomes.

If random paid items are ever added, the implementation must comply with current Roblox rules including visible numerical odds and PolicyService restrictions.

All purchase granting must occur authoritatively and safely server-side.

Receipts must be idempotently processed.

Purchases must survive disconnections/retries without duplicate grants.

---

## UI / UX

Use a highly readable mobile-first interface.

Avoid excessive menu buttons.

The game world itself should communicate important information whenever possible.

Prioritize:

- large tap targets
- clear hierarchy
- low text density
- strong iconography
- visible progress
- immediate action feedback
- accessible contrast
- responsive layouts
- safe-area handling

Every meaningful action must generate feedback.

Pickup:
sound + animation + UI confirmation.

Successful extraction:
large audiovisual payoff.

Museum placement:
physical transformation and visitor reaction.

Upgrade:
visible world change.

Rare discovery:
distinct but not excessively lengthy celebration.

Never make the player repeatedly dismiss modal windows during normal play.

---

## AUDIO

Audio is a major part of artifact personality.

Create reusable audio categories:

- pickup
- carry strain
- artifact idle
- artifact reaction
- danger cue
- portal instability
- extraction
- museum placement
- rare discovery

Rare artifacts should be recognizable partly through sound.

Use positional audio for discovery where appropriate.

Do not overload the mix.

Provide accessible volume settings.

---

## VISUAL STYLE

The game must look intentional rather than like a default Roblox simulator template.

Avoid generic neon UI frames, endless rectangular upgrade pads and copied simulator aesthetics.

Use a coherent strange-science/adventure visual identity.

The hub should feel like a mysterious but welcoming research complex.

Rifts can have dramatically different palettes while maintaining consistent interaction language.

Artifacts should prioritize readable silhouettes.

An artifact should ideally be recognizable at thumbnail scale.

Design for screenshots and video clips.

---

## PERFORMANCE

Mobile is a first-class platform.

Design around low-to-mid-tier hardware.

Profile frequently.

Control:

- part counts
- physics assemblies
- particle budgets
- texture memory
- mesh complexity
- script scheduling
- replication
- network traffic
- active NPC counts
- museum object counts

Use level-of-detail or simplified distant representations where appropriate.

Do not simulate expensive artifact behaviour when no relevant player is nearby.

Object interactions should degrade gracefully.

Test loading/join time.

Players should gain movement control as soon as practical.

---

## CLIENT / SERVER ARCHITECTURE

The server is authoritative.

Never trust:

- currency values
- inventory ownership
- artifact rarity
- mutation result
- damage
- movement-derived rewards
- purchase completion
- trade content
- extraction success
- quest completion

when supplied by the client.

Client requests intent.

Server validates intent and produces state changes.

Validate:

- argument types
- permissions
- distance
- state
- cooldowns
- ownership
- maximum rates
- expected sequence
- economic limits

Rate-limit remotes.

Separate networking responsibilities cleanly.

Use RemoteEvents where one-way asynchronous communication is appropriate.

Do not expose arbitrary object paths or unrestricted instance references through remotes.

Implement exploit telemetry.

Prefer preventing an exploit's economic impact before relying on punishment.

---

## DATA

Create a versioned player data schema.

Example conceptual structure:

- Profile
- Version
- Currencies
- Museum
- Artifacts
- CollectionProgress
- Equipment
- Research
- Quests
- Achievements
- Cosmetics
- Settings
- Statistics
- PurchaseEntitlements

Artifacts require immutable unique instance identifiers where necessary.

Never identify valuable unique possessions only by item type.

Design migrations before live release.

Persistence operations must be fault tolerant.

Avoid excessive DataStore writes.

Use session-safe patterns.

Protect against duplication caused by retries, crashes and multi-server race conditions.

---

## CROSS-SERVER SYSTEMS

Use durable stores for persistent player state.

Use appropriate ephemeral shared systems for transient global state.

Cross-server event notifications must tolerate dropped messages.

A missed cross-server message must not corrupt economy or permanent inventory.

If implementing global markets, leaderboards or match queues, separate strongly consistent economic requirements from display-only/event-notification requirements.

---

## ANALYTICS

Instrument the onboarding funnel.

At minimum capture:

- session_started
- character_ready
- portal_seen
- first_rift_entered
- first_artifact_seen
- first_artifact_picked_up
- first_extraction_attempted
- first_extraction_success
- first_museum_placement
- first_currency_earned
- first_upgrade
- second_rift_entered
- collection_book_opened
- museum_visited
- party_joined
- trade_started
- trade_completed
- shop_opened
- purchase_started
- purchase_completed
- session_ended

Add timestamps and relevant contextual properties.

Measure time-to-event.

Monitor:

- first-play bounce
- PTR
- D1 retention
- D7 retention
- D30 retention
- average session duration
- sessions per user
- play days per user
- intentional co-play
- funnel completion
- conversion rate
- ARPDAU
- ARPPU
- item purchase mix
- crashes
- join time
- server performance

Do not optimize only revenue.

A monetization change that increases short-term ARPDAU while damaging D1/D7 or approval should be treated with suspicion.

---

## EXPERIMENTATION

Create configuration infrastructure allowing selected parameters to be changed without restructuring systems.

A/B test meaningful hypotheses.

Examples:

- first Rift length
- first artifact distance
- initial currency
- first upgrade timing
- collection-book reveal timing
- number of visible future goals
- Rift difficulty ramp
- museum visitor feedback intensity

Change one hypothesis at a time when practical.

Define expected metric impact before running the experiment.

Avoid post-hoc rationalization.

---

## CONTENT ROADMAP

MVP should prove only the emotional core.

MVP approximately requires:

- one hub
- one personal museum
- one Rift
- roughly 15 highly differentiated artifacts
- basic carrying
- basic hazards
- extraction
- museum placement
- basic persistence
- basic progression
- basic analytics

Do not build twenty worlds before proving that physically recovering strange artifacts is fun.

Prototype until strangers understand the loop without developer explanation.

After core validation:

- add multiple Rifts
- mutations
- collection book
- cooperative carrying
- museum expansion
- events
- quests
- trading
- LiveOps
- monetization

Only scale marketing once the product's retention is competitive.

---

## QUALITY BAR

Reject features that exist only because other Roblox games have them.

Every feature must answer at least one of these:

- Does it make the core action more fun?
- Does it create meaningful progression?
- Does it deepen player identity?
- Does it create social interaction?
- Does it create replayable uncertainty?
- Does it create a memorable story?
- Does it create sustainable content production?
- Does it improve business sustainability without harming players?

If the answer to all is no, remove it.

---

## FINAL PRODUCT TEST

Before considering the project ready for major promotion, a first-time player should be able to answer the following without reading documentation:

- What am I supposed to do?
- Why is it fun?
- What do I own?
- What do I want next?
- Why would I return tomorrow?
- Why would I invite a friend?
- What can I eventually become?

If those answers are not obvious from gameplay itself, continue iterating.

The ultimate objective is not maximum minutes extracted from a player.

The objective is to create a game people repeatedly choose because the actions are satisfying, the discoveries feel personal, the world keeps surprising them, their collection means something, and their friends make the experience better.

Build **GRAB THE WEIRD!** around that principle.
