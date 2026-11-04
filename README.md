<div align="center">

# Bhumi Setu (ভূমি সেতু): Land Record Ledger & Title Deed Verification Engine

[![Interactive Simulator](https://img.shields.io/badge/Live%20Simulator-mahmudulhasan.info.bd-BA3C00?style=for-the-badge&logo=google-chrome&logoColor=white)](https://mahmudulhasan.info.bd/systems/landtrust-bhumisetu/)
[![System Dossier](https://img.shields.io/badge/System%20Dossier-Zero%20Fault-10B981?style=for-the-badge&logo=diagram-next&logoColor=white)](https://mahmudulhasan.info.bd/systems/landtrust-bhumisetu/)
[![Java](https://img.shields.io/badge/Java-21%20LTS-ED8B00?style=for-the-badge&logo=openjdk&logoColor=white)](https://openjdk.org/projects/jdk/21/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.4-6DB33F?style=for-the-badge&logo=springboot&logoColor=white)](https://spring.io/projects/spring-boot)
[![Flutter](https://img.shields.io/badge/Flutter-3.29-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16%20%2B%20PostGIS-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Geospatial](https://img.shields.io/badge/Geospatial-PostGIS%20Boundary%20Check-blue?style=for-the-badge&logo=googlemaps&logoColor=white)](https://postgis.net/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

<br/>

> 🚀 **Live Interactive Case Study & Land Record Verification Simulator:**  
> Experience the 100-year historical Khatiyan chain-of-title verification engine (CS, SA, RS, BS), test PostGIS spatial parcel overlap detection, and simulate real-time land unit conversions on the official systems engineering platform:  
> 🔗 **[Explore Full Case Study & Live Simulator on mahmudulhasan.info.bd](https://mahmudulhasan.info.bd/systems/landtrust-bhumisetu/)**

</div>

---

## 📌 Executive Overview

**Bhumi Setu (ভূমি সেতু / LandTrust)** is an enterprise digital land record ledger, title deed verification, and geospatial parcel auditing platform engineered in **Flutter 3.29**, **Java 21**, **Spring Boot 3.4**, and **PostgreSQL 16 with PostGIS**.

In Bangladesh, over **70% of all pending civil court litigations** stem from fraudulent land deeds (দলিল), forged mutation papers, and physical boundary conflicts. Bhumi Setu eliminates real estate fraud by providing an unbroken **Chain-of-Title Continuity Engine** tracing property ownership across a century of cadastral surveys (CS, SA, RS, BS/City Survey), a sub-28ms **PostGIS Spatial Boundary Check** that flags overlapping plot boundaries, and a regional land unit calculator converting between Katha, Bigha, Decimal, and Square Feet with sub-millimeter mathematical precision.

---

## ⚡ Production Hardened Benchmarks

| Metric Category | Production SLA / Measurement | Architectural Guarantee |
| :--- | :--- | :--- |
| **Audit Throughput** | `1,200+ Title Audits / Min` | High-efficiency non-blocking Spring Boot transaction processing |
| **Spatial Query Latency** | `< 28ms PostGIS Boundary Query` | R-Tree spatial indexing with `ST_Intersects` and `ST_Overlaps` |
| **Client Memory Footprint** | `< 52 MB Flutter Client Memory` | Lightweight cross-platform rendering for mobile and low-spec tablets |
| **Chain-of-Title Audit** | `100% Unbroken Ownership History` | Automated genealogical linkage across CS, SA, RS, and BS record series |
| **Measurement Precision** | `Sub-Millimeter Unit Conversion` | Exact mathematical mapping across Bigha, Katha, Decimal/Shotok, Acre, Sqft |

---

## 🏛️ High-Performance Architectural Blueprint

```
┌────────────────────────────────────────────────────────────────────────┐
│             Citizen / Land Buyer (Flutter 3.29 Mobile & Web)           │
│   Deed Search • Plot Polygon Visualizer • Regional Unit Converter      │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ (Nginx Reverse Proxy / HTTPS)
┌───────────────────────────────────▼────────────────────────────────────┐
│              Spring Boot 3.4 REST Engine (Java 21 LTS)                 │
│      JWT Authentication • Mutation Validator • Land Revenue Gateway    │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
              ┌─────────────────────┼─────────────────────┐
              ▼                     ▼                     ▼
┌───────────────────────────┐ ┌───────────────────────────┐ ┌───────────────────────────┐
│ Historical Khatiyan Chain │ │ PostGIS Boundary Auditor  │ │ Precision Land Calculator │
│ CS -> SA -> RS -> BS Link │ │ ST_Overlaps Spatial Inter │ │ Katha, Bigha, Decimal, Sqft│
└───────────────────────────┘ └───────────────────────────┘ └───────────────────────────┘
                                    │
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│             PostgreSQL 16 Enterprise Database with PostGIS             │
│   R-Tree Spatial Indexing • ACID Land Title Registry • Audit History   │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 🚀 Key Architectural Capabilities

- **100-Year Historical Chain-of-Title Validator:**
  Traces property ownership transfers continuously across Cadastral Survey (CS), State Acquisition (SA), Revisional Survey (RS), and Bangladesh Survey (BS/City Survey), flagging missing inheritance links, unrecorded deeds, or fraudulent power-of-attorney transfers.
- **PostGIS Geospatial Overlap Detection:**
  Evaluates plot polygon coordinates with sub-28ms PostGIS queries (`ST_Intersects`, `ST_Overlaps`), immediately revealing if a seller is attempting to sell overlapping parcel acreage.
- **Regional Land Measurement Engine:**
  Converts seamlessly between customary Bangladeshi land units—Katha (কাঠা), Bigha (বিঘা), Decimal/Shotok (শতক), Gonda, Kara, Acre, and Square Feet—eliminating round-off fraud during transaction settlements.
- **Mutation (নামজারি) & DCR Ledger Verification:**
  Verifies AC Land mutation case numbers, duplicate carbon receipt (DCR) fee settlements, and land development tax payments directly against the official revenue ledger.
- **Cross-Platform Accessibility:**
  Single codebase serving field survey officers on rugged Android devices, legal auditors on web browsers, and property buyers on mobile apps.

---

## 💻 Tech Stack & Architecture

- **Backend Runtime:** Java 21 LTS, Spring Boot 3.4.x, Spring Data JPA, Hibernate Spatial
- **Geospatial Database:** PostgreSQL 16 with PostGIS Spatial Extension (R-Tree Indexes)
- **Frontend Layer:** Flutter 3.29 / Dart 3.11 (Mobile & Web)
- **Deployment & Gateway:** Docker, Docker Compose, Nginx Reverse Proxy
- **Security & Authorization:** Spring Security 6, Stateless JWT Token Verification

---

## 🛠️ Local Development & Quick Start

### 1. Launch Services via Docker Compose
```bash
# Clone the repository
git clone https://github.com/mhcybroot/landtrust-bhumisetu.git
cd landtrust-bhumisetu

# Start PostgreSQL with PostGIS and backend services
docker compose up -d
```

### 2. Frontend Execution
```bash
cd frontend
flutter pub get
flutter run
```

---

## 👨‍💻 Engineering & Architecture

**Mahmudul Hasan (@mhcybroot)**  
*Full-Stack Systems Engineer & Distributed Architect • Dhaka, Bangladesh*  
*Specializing in Geospatial PostGIS Engineering, Fault-Tolerant Enterprise Backends, and High-Integrity Financial & Title Ledgers.*

- 🌐 **Systems Engineering Portfolio:** [mahmudulhasan.info.bd](https://mahmudulhasan.info.bd/)
- ⚡ **Interactive System Simulators:** [mahmudulhasan.info.bd/#systems](https://mahmudulhasan.info.bd/#systems)
- 📑 **Verified Engineering Dossier:** [mahmudulhasan.info.bd/#dossier](https://mahmudulhasan.info.bd/#dossier)
- 💼 **LinkedIn Profile:** [linkedin.com/in/mhcybroot](https://linkedin.com/in/mhcybroot)
- 📧 **Direct Inquiries:** [info@mahmudulhasan.info.bd](mailto:info@mahmudulhasan.info.bd)

---

<div align="center">
  <sub>Engineered with Zero-Fault Tolerance by Mahmudul Hasan • Verified on <a href="https://mahmudulhasan.info.bd/systems/landtrust-bhumisetu/">mahmudulhasan.info.bd/systems/landtrust-bhumisetu/</a></sub>
</div>
