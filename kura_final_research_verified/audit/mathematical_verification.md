# Mathematical and Algorithmic Forensic Audit

**Auditor**: Mathematical Verification Specialist  
**Target Manuscript**: Kura Project Manuscript  
**Date**: November 20, 2026  

---

## 1. Audit of Formal Claims and Words of Absolute Guarantee

The manuscript was audited for overgeneralized words of guarantee: `optimal`, `guarantees`, `exact`, `minimizes`, `proves`, `zero-copy`, `asymptotically`, and `universally`.

### 1.1 Loom Spectral Graph Partitioning (Section 8)
- **Problematic Claim**: *"This permutation minimizes the cut weight..."*
- **Mathematical Reality**:
  The discrete 1D Minimum Linear Arrangement (1D-MLA) problem:
  $$\min_{\pi} \sum_{i < j} w_{ij} (\pi(i) - \pi(j))^2$$
  is NP-hard. Spectral graph theory (Hall, 1970; Spielman, 2007) solves the continuous relaxation:
  $$\min_{v \in \mathbb{R}^n, v \perp \mathbf{1}, \|v\|_2 = 1} v^T L_{\text{norm}} v$$
  where the exact continuous minimizer is the Fiedler vector $v_2$ corresponding to the second smallest eigenvalue $\lambda_2$. Sorting the coordinates of $v_2$ produces a discrete permutation $\pi$ that serves as an approximation heuristic.
- **Correction**: Replaced "minimizes the cut weight" with:
  *"Sorting the Fiedler vector coordinates yields a discrete permutation $\pi$ that serves as a standard continuous spectral relaxation heuristic approximating 1D physical placement."*

### 1.2 Scarcity Pricing Stability (Section 7 & Appendix B)
- **Mathematical Statement**: Theorem 1 states that under convex scarcity pricing $P_{\text{scarcity}}(U) = P_0 \exp\left(\frac{\beta}{1-U}\right)$ with bounded utility $\text{MEC}(F_i) \le M_{\max} < \infty$, utilization ratio $U(t)$ strictly satisfies $U(t) \le 1 - \delta < 1$.
- **Verification**: Derivation verified:
  $$P_0 \exp\left(\frac{\beta}{1-U}\right) \le \frac{M_{\max}}{\mathcal{S}_{\text{exp}}} \implies 1-U \ge \frac{\beta}{\ln\left(\frac{M_{\max}}{P_0 \mathcal{S}_{\text{exp}}}\right)} > 0$$
  The proof holds rigorously under the stated assumption of bounded utility and strictly positive base pricing.

### 1.3 Routing Forecasting Model (Section 7)
- **Mathematical Description**: The paper referenced "Conditional Random Fields (CRF)" for router forecasting.
- **Implementation Check**: The codebase in `crates/kura-kaef` implements intermediate logit quantile estimation and entropy tracking rather than a dense linear-chain CRF graph solver.
- **Correction**: Adjusted terminology from "Conditional Random Field" to *"router entropy quantile estimation and lookahead frontier filtering"*, accurately reflecting the actual Rust implementation.

### 1.4 Bit-Level Mathematical Equivalence (Section 10 & 11)
- **Problematic Claim**: *"Kura maintains universal bit-level equivalence..."*
- **Mathematical Truth**: Equivalence ($\Delta L_2 = 0.0$, cosine similarity $= 1.0$) was empirically validated across 262 deterministic test assertions in the automated test suite for the implemented synthetic MoE and OLMoE-1B-7B layer/kernel implementations under f32 and Q4_K_M/Q8_0 formats. It is not an unconstrained proof across all arbitrary neural architectures or floating-point rounding modes.
- **Correction**: Scoped precisely to the evaluated test suite.
