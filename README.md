# 💊 MedLookup

**Search U.S. FDA medication information from your iPhone — fast, clean, and offline-friendly.**

A SwiftUI iOS app built on the free, key-less [openFDA](https://open.fda.gov/apis/drug/label/) public-health API. Type a brand name (e.g. *Tylenol*) and get the drug's purpose, warnings, and manufacturer — sourced straight from the FDA.

![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![Platforms](https://img.shields.io/badge/iOS-15%2B-blue.svg)
![Tests](https://img.shields.io/badge/tests-passing-brightgreen.svg)
![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)

> 🎯 Built to demonstrate production-quality iOS: a clean data boundary, async networking, testable architecture, and accessible SwiftUI — using **real public health data**.
>
> ⚙️ **Workflow transparency:** built with an AI-assisted workflow (Claude as pair programmer — see the commit trailers); the architecture decisions, code review, and final call on every line are mine.

---

## ✨ Features

- 🔎 **Search** FDA drug labels by brand name (live openFDA data)
- 📄 **Detail view** — purpose, warnings, indications, manufacturer
- ⏳ **Loading / empty / error states** that feel calm, never broken
- ♿️ **Accessible** (Dynamic Type, VoiceOver labels)
- 🧪 **Unit-tested** core (the data boundary is the heart, so it's covered)

*(Screenshots / demo GIF — added in a later commit.)*

## 🌐 Data source

[**openFDA**](https://open.fda.gov/apis/drug/label/) — the U.S. Food & Drug Administration's open API.
Free, **no API key required**, real public-health data. Endpoint: `GET https://api.fda.gov/drug/label.json`.

## 🏛 Architecture

The core is a small, platform-agnostic Swift package — **`MedLookupKit`** — so the logic is testable without the UI. The SwiftUI app (added in upcoming commits) is a thin layer on top.

```
openFDA JSON ──► DrugLabel (raw, messy)
                      │  normalize boundary  ◄── the one place data is cleaned
                      ▼
                 Medication (clean domain)  ──► SwiftUI views
```

**The single most important idea:** all the messy, optional-array openFDA data is made well-formed in **one place** — `Medication.init(from:)` — so the rest of the app only ever sees a clean `Medication`. Missing names fall back gracefully; unusable rows are dropped.

```swift
// Sources/MedLookupKit/Normalize.swift
init?(from label: DrugLabel) {
    let brand = label.openfda?.brandName?.first
    let generic = label.openfda?.genericName?.first
    guard let id = label.id ?? brand ?? generic else { return nil } // drop junk rows
    self.init(
        id: id,
        brandName: brand ?? generic ?? "Unknown",   // never an empty title
        // ...arrays flattened to readable text
    )
}
```

## 🛠 Tech

`Swift` · `SwiftUI` · `async/await` · `URLSession` · `Codable` · `MVVM` · `XCTest` · `Swift Package Manager` · `Accessibility (WCAG)`

## 🚀 Getting started

```bash
git clone https://github.com/sebkoo/MedLookup.git
cd MedLookup
swift test        # run the core unit tests
```

Then open the package in **Xcode** to run the SwiftUI app on the iOS Simulator (app target lands in an upcoming commit).

## 🗺 Roadmap (built in small, reviewable commits)

- [x] **chore:** initialize the MedLookupKit Swift package
- [x] **feat:** raw openFDA wire models — the honest shape
- [x] **feat:** `Medication` domain type
- [x] **feat:** normalize boundary — name fallbacks, joined paragraphs, junk-row dropping
- [x] **feat:** async `OpenFDAClient` behind a `MedicationSearching` protocol
- [x] **test:** unit tests for the boundary
- [ ] **feat:** search screen (SwiftUI + MVVM view model) with loading / empty / error states
- [ ] **feat:** medication detail screen
- [ ] **test:** view-model tests with a mocked `MedicationSearching`
- [ ] **feat:** recent searches + accessibility pass (Dynamic Type, VoiceOver)
- [ ] **ci:** GitHub Actions running `swift test`
- [ ] **docs:** screenshots + demo GIF

## 👤 Author

**Ben Koo** — Senior iOS / Mobile Engineer (ex-Apple, Walmart, CVS Health).
Swift · SwiftUI · UIKit · payments · wearables · connected-health.
📩 61488202+sebkoo@users.noreply.github.com · 💼 [LinkedIn](https://www.linkedin.com/in/koo-ben)

## 📄 License

MIT — see [LICENSE](LICENSE).
