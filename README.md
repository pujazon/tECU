# tECU
Self-driven, hands-on engineering project created to explore, master, and experiment with production-grade automotive firmware architecture for STM32.

## 🛠 Project Overview

This project implements a deterministic, production-grade ECU application designed to manage autonomous vehicle dynamics, real-time telemetry, and safety-critical functions (ADAS). The architecture bridges low-level hardware abstraction with high-level software engineering practices, running on top of a static **FreeRTOS** kernel and strictly avoiding dynamic memory allocation (`new`/`delete`) for maximum memory predictability.

---

## 🧰 Hardware & Toolchain

* **Target Microcontroller:** STM32 (ARM Cortex-M3/M4)
* **Peripherals & Interfaces:** bxCAN/FDCAN, USART (DMA/Interrupts), TIM (PWM Generation), GPIO, Ultrasonic Sensors (HC-SR04).
* **Wireless Gateway:** Bluetooth (HC-05/06) pass-through module.
* **Actuators:** Dual DC Motor Driver (H-Bridge L298N/TB6612FNG) on a 2WD robot chassis.
* **Toolchain:** `arm-none-eabi-gcc`, C++17, CMake / STM32Cube.

---

## 🏗 Key Engineering Highlights

* **Static RTOS Core:** Built on FreeRTOS using purely static memory allocation (`xTaskCreateStatic`, static queues, and semaphores).
* **Automotive Networking:** Native CAN bus integration with hardware filtering, frame multiplexing, and custom telemetry signals.
* **Zero-Overhead HAL:** Object-oriented C++ abstraction wrappers over low-level MCU registers without dynamic allocation or virtual table overhead where critical.
* **Automated CI/CD & Emulation:** Self-hosted CI runner executing on a Raspberry Pi, performing automated cross-compilation builds and system-level integration tests via STM32 emulation (**Renode / QEMU**).

---
## 🛠️ Build & Toolchain

This project uses an independent build system based on **GNU Make** and the **Arm GNU Toolchain (`arm-none-eabi-g++`)** cross-compiler. The build system is completely decoupled from any vendor IDE (such as Keil or STM32CubeIDE) to ensure consistent compilation across local developer environments and Continuous Integration (CI/CD) pipelines.

---

### 1. Prerequisites

Before building the project, ensure you have the following tools installed on your system:

| Tool | Recommended Version | Description |
| :--- | :--- | :--- |
| **Arm GNU Toolchain** | `13.x` or higher (`arm-none-eabi-gcc` / `g++`) | Official cross-compiler for ARM Cortex-M |
| **GNU Make** | `4.x` (`mingw32-make` on Windows) | Build automation engine |

---

### 2. Local Environment Setup (`local_env.cfg`)

To avoid hardcoding system-absolute paths into the repository and to allow developers to configure their own installation paths without altering Git tracking:

1. Navigate to the `./scripts/` directory.
2. Copy `local_env.cfg.template` to `local_env.cfg`:
   ```bash
   # On Windows (CMD)
   copy scripts\local_env.cfg.template scripts\local_env.cfg
   ```
   # On Linux / macOS
   cp scripts/local_env.cfg.template scripts/local_env.cfg