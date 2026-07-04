# MedLookup — Project Plan

A short, honest planning doc written before the code — the way I'd start a real feature.

## 1. Problem

People often have a medication in hand and a simple question: *what is this for, and what should I watch out for?* Authoritative answers exist (the FDA), but they're buried in dense web pages. A focused mobile app can surface the essentials in seconds.

## 2. Users & scope

- **User:** anyone who wants quick, trustworthy drug information.
- **MVP scope:** search by brand name → list of matches → detail (purpose, warnings, indications, manufacturer).
- **Out of scope (v1):** accounts, reminders, interactions checker, barcode scanning. (Good follow-ups, not needed to prove the engineering.)

## 3. Data source research

- **openFDA `drug/label`** — https://open.fda.gov/apis/drug/label/
- Free, **no API key** (rate-limited: ~240 req/min, 1,000/day without a key — plenty for a demo).
- Endpoint: `GET https://api.fda.gov/drug/label.json?search=openfda.brand_name:"tylenol"&limit=25`
- Response shape: `{ "meta": {…}, "results": [ { … } ] }`.
- **Reality of the data:** almost every useful field is an *optional array of strings* (`openfda.brand_name`, `purpose`, `warnings`, …), and some rows are missing names entirely. This is exactly why a normalize boundary matters.

## 4. Domain model

| Raw (`DrugLabel`, wire) | Clean (`Medication`, app) |
| --- | --- |
| `id: String?` | `id: String` (guaranteed) |
| `openfda.brand_name: [String]?` | `brandName: String` (falls back to generic, then "Unknown") |
| `openfda.generic_name: [String]?` | `genericName: String?` |
| `purpose: [String]?` | `purpose: String?` (paragraphs joined) |
| `warnings: [String]?` | `warnings: String?` |

Cleaning happens once, in `Medication.init(from:)`. Screens never see the raw shape.

## 5. Architecture

- **`MedLookupKit`** (Swift package): models, normalize boundary, `OpenFDAClient` behind a `MedicationSearching` protocol. Platform-agnostic and unit-tested.
- **App** (SwiftUI, MVVM): a view model calls `MedicationSearching`; views render clean `Medication` values with loading / empty / error states.
- **Why a protocol?** so the view model is tested against a mock, with no network.

## 6. Milestones (one small commit each)

1. **Setup + core** — models, normalize, client, tests ✅ *(this commit)*
2. Search screen (view model + states)
3. Detail screen
4. View-model tests with a mocked client
5. Recent searches + accessibility pass
6. CI (GitHub Actions → `swift test`)
7. Screenshots + demo GIF

## 7. Decisions / tradeoffs

- **Normalize at one boundary** over scattering guards across views — one place to fix, honest types, fewer crashes.
- **A testable core package** over putting logic in views — the important logic is verified without a simulator.
- **No API key** keeps the project trivially runnable by anyone reviewing it.
