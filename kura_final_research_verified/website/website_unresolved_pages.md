# KURA Website Unresolved Pages and Dynamic Resources Report

**Target Website**: https://kuracpu.vercel.app  
**Date of Audit**: November 20, 2026  

---

## 1. Unresolved or Dynamic Resources

During the forensic extraction of the Kura project website, all static documentation routes were 100% captured into `accessible_content_archive.json`. However, several dynamic, client-side interactive, or external resources were inspected and categorized:

| Resource Identifier | Resource Type | Nature / Purpose | Operational Status / Audit Resolution |
| :--- | :--- | :--- | :--- |
| `/mini-me.js` | Client-Side Interactive Widget | Interactive avatar/chat widget created by Fraol Teshome. | Dynamic client-side DOM injector; contains no empirical benchmark data. Safely excluded from manuscript. |
| `https://github.com/fraol163/kura-benchmarks` | External Repository | Official public source code and benchmark repo. | Active external GitHub link; verified in repository cross-check. |
| `https://huggingface.co/allenai/OLMoE-1B-7B-0924` | External Checkpoint | Weight repository for OLMoE-1B-7B GGUF models. | External checkpoint host; verified as authentic open-weight model. |
| Google Drive Upload Endpoint | Cloud Storage | User request to upload deliverables to Google Drive. | **Unresolved**: No local Google Drive mount, `rclone`, or cloud API credentials exist on the host machine. Addressed via local archive creation. |
| Backend Metrics API | Server Endpoint | Telemetry collection. | **None Exists**: Website strictly adheres to a Zero-Telemetry rule; no server-side telemetry or user-tracking endpoints are implemented. |

---

## 2. Integrity Verification

All 44 core documentation pages are fully preserved locally. No critical documentation or experimental evidence remains un-extracted from the website.
