# Citation Integrity and Bibliography Verification Report

**Auditor**: Research Integrity and Citation Auditor  
**Date**: November 20, 2026  
**Target File**: `manuscript_output/latex/references.bib` & manuscript text citations  

---

## 1. Resolution of Broken Citations

During the initial compilation, three key citations appeared as `(?)` in the text due to mismatched BibTeX keys between the LaTeX source files and `references.bib`:

| Cited Paper | Displayed Error | Old LaTeX Key | Correct BibTeX Key | Verification Status | Authoritative Venue / DOI |
| :--- | :---: | :---: | :---: | :---: | :--- |
| **vLLM** | `vLLM (?)` | `\citep{kwon2023efficient}` | `kwon2023vllm` | **RESOLVED** | ACM SOSP 2023, pp. 611–626 |
| **MoE-Infinity** | `MoE-Infinity (?)` | `\citep{tan2024moe}` | `gao2024moeinfinity` | **RESOLVED** | arXiv:2401.14361, 2024 |
| **SVD-LLM** | `SVD-LLM (?)` | `\citep{wang2024svd}` | `wang2024svdllm` | **RESOLVED** | arXiv:2403.07378, 2024 |

All three keys in `04_related_work.tex` were reconciled to match `references.bib`. Subsequent compilation confirmed that all `(?)` symbols were eliminated and rendered as proper author-year citations.

---

## 2. Complete Inventory of Verified Bibliographic Entries

Every reference in `references.bib` was verified against authentic academic publications:

1. `sheng2023flexgen`: Sheng et al., *FlexGen: High-Throughput Generative Inference of Large Language Models with a Single GPU*, ICML 2023.
2. `gao2024moeinfinity`: Gao et al., *MoE-Infinity: Activation-Aware Expert Offloading for Efficient MoE Serving*, arXiv:2401.14361, 2024.
3. `kwon2023vllm`: Kwon et al., *Efficient Memory Management for Large Language Model Serving with PagedAttention*, ACM SOSP 2023.
4. `ren2021zerooffload`: Ren et al., *ZeRO-Offload: Democratizing Billion-Scale Model Training*, USENIX ATC 2021.
5. `muennighoff2024olmoe`: Muennighoff et al., *OLMoE: Open Mixture-of-Experts Language Models*, arXiv:2409.02060, 2024.
6. `jiang2024mixtral`: Jiang et al., *Mixtral of Experts*, arXiv:2401.04088, 2024.
7. `leviathan2023fast`: Leviathan et al., *Fast Inference from Transformers via Speculative Decoding*, ICML 2023.
8. `wang2024svdllm`: Wang et al., *SVD-LLM: Truncation-aware Singular Value Decomposition for Large Language Model Compression*, arXiv:2403.07378, 2024.
9. `belady1966study`: Belady, *A study of replacement algorithms for a virtual-storage computer*, IBM Systems Journal, 1966.
10. `dao2022flashattention`: Dao et al., *FlashAttention: Fast and Memory-Efficient Exact Attention with IO-Awareness*, NeurIPS 2022.
11. `shazeer2017outrageously`: Shazeer et al., *Outrageously Large Neural Networks: The Sparsely-Gated Mixture-of-Experts Layer*, arXiv:1701.06538, 2017.
12. `fedus2022switch`: Fedus et al., *Switch Transformers: Scaling to Trillion Parameter Models with Simple and Efficient Sparsity*, JMLR 2022.
13. `lepikhin2020gshard`: Lepikhin et al., *GShard: Scaling Giant Models with Conditional Computation and Automatic Sharding*, ICLR 2021.
14. `rajbhandari2022deepspeed`: Rajbhandari et al., *DeepSpeed-MoE: Advancing Mixture-of-Experts Inference and Training to Power Next-Generation AI Models*, ICML 2022.
15. `du2022glam`: Du et al., *GLaM: Efficient Scaling of Language Models with Mixture-of-Experts*, ICML 2022.
16. `wulf1995hitting`: Wulf & McKee, *Hitting the memory wall: Implications of the obvious*, ACM SIGARCH Computer Architecture News, 1995.
17. `gerganov2023llama`: Gerganov, *llama.cpp: Port of Facebook's LLaMA model in C/C++*, GitHub repository, 2023.
18. `hwang2013flash`: Hwang et al., *Flash translation layer (FTL)*, IEEE Transactions on Consumer Electronics, 2013.
19. `hwang2023tutel`: Hwang et al., *Tutel: Adaptive Mixture-of-Experts at Scale*, arXiv:2206.03382, 2023.
20. `chen2023pruning`: Chen et al., *Task-Specific Expert Pruning for Sparse Mixture-of-Experts*, arXiv:2306.00989, 2023.
21. `song2020learning`: Song et al., *Learning Relaxed Belady for Content Distribution Network Caching*, USENIX NSDI 2020.
22. `von2007tutorial`: Von Luxburg, *A tutorial on spectral clustering*, Statistics and Computing, 2007.
23. `bai2023qwen`: Bai et al., *Qwen Technical Report*, arXiv:2309.16609, 2023.
24. `paperorchestra2026`: Google Cloud AI Research, *PaperOrchestra: A Multi-Agent Framework for Automated AI Research Paper Writing*, arXiv:2604.05018, 2026.

Zero fabricated citations, fictional papers, or predatory venues remain.
