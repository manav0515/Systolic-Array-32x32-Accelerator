# 32×32 Pipelined Systolic Array Matrix Multiplication Accelerator (RTL-to-GDSII)

A production-grade, high-throughput **Domain-Specific Spatial Accelerator** architected for dense Matrix Multiplication ($C = A \times B$), targeting modern Artificial Intelligence (AI) and Deep Learning workloads. The complete design has been physically realized via an industrial **RTL-to-GDSII ASIC implementation flow** utilizing the Synopsys toolchain on an industrial **32nm Standard Cell Library**. 

---

## 📌 Technical Specifications & PDK Corner

| Parameter | Specification / Tool Archetype |
| :--- | :--- |
| **Matrix Dimensions** | 32 Rows × 32 Columns |
| **Compute Engine Count** | 1,024 Processing Elements (PEs) |
| **Total Flip-Flop Load** | 82,688 Registers |
| **Output Data Width** | 32,768-bit wide Parallel Output Bus (`result_bus`) |
| **Technology Node** | SAED 32nm RVT (Regular Voltage Threshold) Process |
| **Signoff Operating Corner** | `saed32rvt_ss0p7vn40c` (Worst-Case Slow: $0.7\text{V}$, $-40^\circ\text{C}$) |
| **Target Signoff Frequency** | 133.33 MHz (Clock Period = **7.50 ns**) |

---

## 🧠 Micro-Architectural Blueprint & Pipelining Strategy

### The Spatial Data Flow
The accelerator uses a **Output-Stationary / Weight-Streaming** systolic data flow mesh. 
* **Horizontal Stream (`a_bus`):** Input activations enter the left boundary matrix pins and propagate horizontally from left to right across the columns, delayed by 1 clock cycle per column to maintain temporal alignment.
* **Vertical Stream (`b_bus`):** Weights enter the top boundary matrix pins and shift vertically downward row-by-row through the processing elements.

```text
       B0,0   B0,1   B0,2
        │      │      │
        ▼      ▼      ▼
A0,0 ──►[PE]──►[PE]──►[PE]
        │      │      │
        ▼      ▼      ▼
A1,0 ──►[PE]──►[PE]──►[PE]
        │      │      │
        ▼      ▼      ▼
