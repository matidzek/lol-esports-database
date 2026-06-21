# lol-esports-database

Relational database project modeled after the League of Legends competitive ecosystem. Designed to track tournaments, matches, teams, players, and champion meta across seasons and splits.

Implemented in both **Oracle** and **MS SQL Server**.

---

## Structure

```
lol-esports-database/
├── mssql/
│   ├── MSSQL_01_DDL.sql        # table definitions + constraints
│   ├── MSSQL_02_DML.sql        # seed data
│   ├── MSSQL_03_SKRYPTY.sql    # stored procedures + triggers
│   ├── MSSQL_04_demo.sql       # demo calls
│   └── MSSQL-2026-06-14_16-41.png
└── oracle/
    ├── Oracle_01_DDL.sql
    ├── Oracle_02_DML.sql
    ├── Oracle_03_instrukcje.sql
    ├── Oracle_04_demo.sql
    └── MSSQL-2026-06-14_16-45.png
```

---

## Schema

The time unit throughout the schema is a **split** (up to 3 per season). Most things that change over time — champion stats, team rosters, player roles — are scoped to a split rather than stored globally, since the meta and lineups shift constantly.

**16 tables total.** Core entities:

| Table | Purpose |
|---|---|
| `Sezon` | Season + split number (composite unique key) |
| `Champion` / `Klasa` / `Pozycja` | Champions with class and map positions |
| `Pozycje_championow` | Tier, winrate, pickrate, banrate per champion/position/split |
| `Gracz` / `Druzyny` | Players and teams, both tied to a region |
| `Druzyny_gracza` | Full employment history — who played where, in what role, during which split |
| `Championy_gracza` | Per-split champion pool with individual winrate per player |
| `Turnieje` / `Lokalne` / `Globalne` | Tournaments split into regional (LEC, LCK…) and international (Worlds, MSI) |
| `Druzyny_turniejow` | Team participation + final placement per tournament |
| `Mecze` / `Gry` | Match (best-of series) → individual games |
| `Statystyki_gracza_z_gry` | Per-player per-game stats: champion picked, ban, K/D/A, gold |

---

## Procedures & Triggers

Both versions implement the same logic, adapted to each platform's syntax.

**`KandydaciNaMVP(tournamentId)`** — ranks all players from a given tournament by KDA. Uses a cursor over the joined stats/games/matches tables. If deaths = 0, KDA falls back to kills + assists.

**`TransferGracza(playerId, teamId, splitId, role)`** — handles a player transfer. Closes the current open employment record (sets `Data_opuszcenia` to today) and inserts a new one. Rolls back on any error.

**`WalidacjaDanychGracza`** (trigger, BEFORE INSERT/UPDATE on `Statystyki_gracza_z_gry`) — rejects rows with negative stats or where a player's picked champion matches their own ban.

**`PrzeliczMecz`** (trigger, AFTER INSERT/DELETE on `Gry`) — recalculates the score in `Mecze` automatically based on which team won each individual game. No manual score updates needed.

---

## Running the scripts

**Oracle** — run in SQL*Plus or SQL Developer:
```sql
@Oracle_01_DDL.sql
@Oracle_02_DML.sql
@Oracle_03_instrukcje.sql
@Oracle_04_demo.sql   -- optional
```

**MS SQL Server** — run in SSMS or sqlcmd:
```sql
MSSQL_01_DDL.sql
MSSQL_02_DML.sql
MSSQL_03_SKRYPTY.sql
MSSQL_04_demo.sql     -- optional
```
