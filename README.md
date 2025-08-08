# 8-Point FFT in Verilog (IEEE-754 Floating Point)

This project implements an **8-point Fast Fourier Transform (FFT)** using IEEE-754 single-precision floating point arithmetic in **Verilog**.  
It also includes a **testbench** for simulation in Vivado or any Verilog simulator.

---

## 📂 Files in this Repository
| File | Description |
|------|-------------|
| `fft_8point.v` | Top-level FFT module implementing a 3-stage Cooley-Tukey FFT. |
| `butterfly.v`  | Complex butterfly computation module with floating-point arithmetic. |
| `tb_fft_8point.v` | Testbench for simulating the FFT module with sample inputs. |

---

## 📐 FFT Design
- **Size:** 8-point
- **Arithmetic:** IEEE-754 single-precision floating point
- **Stages:** 3 stages of butterflies
- **Modules used:**
  - `butterfly` — Performs complex addition, subtraction, and multiplication by twiddle factor
  - `fft_8point` — Connects butterfly stages to implement the FFT

---

## ▶ Simulation in Vivado
1. **Create a new Vivado project** (RTL Project, no sources yet).
2. **Add sources**:
   - `fft_8point.v`
   - `butterfly.v`
3. **Add simulation sources**:
   - `tb_fft_8point.v`
4. Set `tb_fft_8point` as the **top module** for simulation.
5. **Run Simulation** → **Run Behavioral Simulation**.
6. The testbench will:
   - Apply the input vector `[1, 2, 3, 4, 4, 3, 2, 1]`
   - Print FFT outputs in hexadecimal IEEE-754 format

