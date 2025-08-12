# 🧮 BMI Calculator in x86-64 NASM Assembly

A simple **standalone BMI calculator** written in x86-64 **NASM** assembly for MacOS  
It takes weight (kg) and height (m) from the user, computes BMI as:
…and prints the result.

---

## 📂 Files

- `BMICalculator.asm` — Main NASM source code
- `README.md` — This file

---

## ✨ Features

- Minimal, readable **NASM** assembly
- Uses SSE2 double-precision floating-point instructions
- Works on **MACHO x86-64** (System V AMD64)

---

## 🛠 Requirements

- **NASM** assembler
- **GCC** (or Clang) for linking
- x86-64 CPU with SSE2 support (almost all modern CPUs)
- Mac (for Windows/Linux, the calling conventions differ)

---

## ⚙️ Build & Run

```bash
# Assemble
nasm -felf64 file.asm -o file.o

# Link
gcc file.o -o file -no-pie -lm

# Run
./file
