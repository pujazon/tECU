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
* **Toolchain:** `arm-none-eabi-gcc` (C++17), GNU Make, `stlink` utilities (`st-flash`, `st-info`).

---

## 🏗 Key Engineering Highlights

* **Static RTOS Core:** Built on FreeRTOS using purely static memory allocation (`xTaskCreateStatic`, static queues, and semaphores).
* **Automotive Networking:** Native CAN bus integration with hardware filtering, frame multiplexing, and custom telemetry signals.
* **Zero-Overhead HAL:** Object-oriented C++ abstraction wrappers over low-level MCU registers without dynamic allocation or virtual table overhead where critical.
* **Automated CI/CD & Emulation:** Self-hosted CI runner executing on a Raspberry Pi, performing automated cross-compilation builds and system-level integration tests via STM32 emulation (**Renode / QEMU**).

---

## 🛠️ Build & Environment Setup

This project uses an independent build system based on **GNU Make** and the **Arm GNU Toolchain (`arm-none-eabi-g++`)**. The build system is completely decoupled from any vendor IDE (such as Keil or STM32CubeIDE) to ensure consistent compilation across local developer environments and Continuous Integration (CI/CD) pipelines.

---

### 1. Prerequisites

Ensure you have the following tools installed on your system:

| Tool | Recommended Version | Description |
| :--- | :--- | :--- |
| **Arm GNU Toolchain** | `13.x` / `15.x` (`arm-none-eabi-gcc` / `g++`) | Official cross-compiler for ARM Cortex-M |
| **GNU Make** | `4.x` (`mingw32-make` on Windows) | Build automation engine |
| **ST-Link Utilities** | `1.8.0` (`st-flash`, `st-info`) | Open-source ST-Link programmer tools |
| **libusb** | `1.0.x` | Required library dependency for `stlink` |

---

### 2. ST-Link Configuration Setup (`config/chips`)

When using standalone builds of `stlink` on Windows, `st-flash` requires access to the target MCU chip description files (`.chipc` / `.chip`). 

Make sure to copy the `config/chips` folder from your `stlink` distribution directory directly into the directory where `st-flash.exe` is located (or into the root of your toolchain path):

```cmd
:: Example for Windows (CMD)
xcopy /E /I "C:\Users\<user>\Documents\Tools\stlink-1.8.0\config\chips" "C:\Users\<user>\Documents\Tools\stlink-1.8.0\stlink-1.8.0-win32\bin\config\chips"