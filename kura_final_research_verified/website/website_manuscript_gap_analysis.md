# KURA Website vs. Manuscript Gap Analysis

This document identifies technical contributions, benchmark configurations, and architectural details present on the official website (https://kuracpu.vercel.app) that were either missing or under-emphasized in earlier manuscript drafts.

---

## 1. Omitted Website Features Discovered

1. **SENSE Introspection Engine**:
   - *Website Content*: SENSE dynamically computes the hardware operational ratio $R = \text{Bandwidth}_{\text{storage}} / \text{Bandwidth}_{\text{memory}}$ to select execution regimes before model boot.
   - *Manuscript Gap*: The manuscript previously jumped directly to KAEF without explaining how the runtime introspects hardware to determine whether memory streaming is viable.
   - *Correction*: Add a concise subsection in Section 6 (System Architecture) detailing the SENSE hardware probe and operational ratio $R$.

2. **Phase 24 Empirical Audit Transparency**:
   - *Website Content*: The website explicitly reports that in Phase 24 testing, 17 principles were PROVEN, but **3 were REJECTED** (KAEF Predictive Lookahead, Single-Stream Atlas Coordination, and Confidence Early-Exit).
   - *Manuscript Gap*: Previous manuscript drafts attempted to portray KAEF as universally successful, omitting the critical systems insight that dynamic predictive lookahead adds synchronization latency that frequently exceeds disk transfer savings in single-stream interactive inference.
   - *Correction*: Prominently highlight this negative result in Section 11 and Section 12, reflecting the website's honesty and scientific rigor.

3. **Step-by-Step Cumulative Speedup Ladder**:
   - *Website Content*: The website documents a 6-step physical ablation ladder on OLMoE 1B-7B (4.9 $\to$ 6.7 $\to$ 9.1 $\to$ 12.2 $\to$ 13.5 $\to$ 15.2 tok/s).
   - *Manuscript Gap*: The manuscript's ablation table was limited to an abstract 4-way comparison. Incorporating the physical speedup ladder reinforces the empirical narrative.

4. **Authorship and Attribution**:
   - *Website Content*: Fraol Teshome is the sole creator and developer (Telegram: `@mememe12334`, GitHub: `fraol163/kura-benchmarks`).
   - *Manuscript Gap*: Earlier drafts contained placeholder group names ("Fraol Teshome").
   - *Correction*: Fully updated to Fraol Teshome as sole author with independent researcher affiliation.
