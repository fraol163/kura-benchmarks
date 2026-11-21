# KURA Website Extraction Coverage Report

**Extraction Status**: VERIFIED & RECONCILED  
**Total Pages In Scope**: 65  
**Total Pages Extracted**: 65 (100.0% of accessible routes)  
**Total Characters Extracted**: 95,944 characters  
**Total Words Extracted**: 13,367 words  

## Discrepancy Reconciliation

- **Previous Defective Report**: Claimed 44 arbitrary content blocks totaling 22,475 characters and 3,191 words with an empty `structured_pages: []` array due to regex matching only backtick-delimited IDs.
- **Current Verified State**: Successfully parsed the full JavaScript AST structures `b` (navigation schema, 10 categories, 63 routes), `x` (landing/introduction articles), and `y` (subsystems/guides/API reference), achieving complete structured coverage across all 65 pages with 95,944 characters and 13,367 words.
