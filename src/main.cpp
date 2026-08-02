#include <cstdint>

namespace HAL {

// Estructura de registros del periférico GPIO en STM32F4
struct GPIO_Registers {
    volatile uint32_t MODER;   // Offset 0x00: Modo (Input, Output, Alt, Analog)
    volatile uint32_t OTYPER;  // Offset 0x04: Tipo de salida (Push-Pull, Open-Drain)
    volatile uint32_t OSPEEDR; // Offset 0x08: Velocidad de salida
    volatile uint32_t PUPDR;   // Offset 0x0C: Pull-up / Pull-down
    volatile uint32_t IDR;     // Offset 0x10: Registro de entrada (Read-Only)
    volatile uint32_t ODR;     // Offset 0x14: Registro de salida
    volatile uint32_t BSRR;    // Offset 0x18: Bit Set / Reset
    volatile uint32_t LCKR;    // Offset 0x1C: Bloqueo de configuración
    volatile uint32_t AFRL;    // Offset 0x20: Función alternativa baja (pins 0..7)
    volatile uint32_t AFRH;    // Offset 0x24: Función alternativa alta (pins 8..15)
};

// Direcciones base en STM32F4 (AHB1 Bus)
constexpr uintptr_t AHB1PERIPH_BASE = 0x40020000U;
constexpr uintptr_t RCC_BASE        = AHB1PERIPH_BASE + 0x3800U;
constexpr uintptr_t GPIOD_BASE      = AHB1PERIPH_BASE + 0x0C00U;

// Punteros a los periféricos
inline auto* const GPIOD_PORT = reinterpret_cast<GPIO_Registers*>(GPIOD_BASE);
inline auto* const RCC_AHB1ENR = reinterpret_cast<volatile uint32_t*>(RCC_BASE + 0x30U);

// Modos de operación para los pines
enum class PinMode : uint32_t {
    Input     = 0x00U,
    Output    = 0x01U,
    Alternate = 0x02U,
    Analog    = 0x03U
};

/**
 * Configura el modo de un pin individual (0 a 15).
 * C++ Zero-overhead: se compila directamente en instrucciones de mascara en ensamblador.
 */
inline bool configure_pin_mode(GPIO_Registers* port, uint8_t pin, PinMode mode) noexcept {
    if (port == nullptr || pin > 15) {
        return false;
    }

    const uint32_t shift = pin * 2U;
    
    // 1. Limpia los 2 bits actuales del modo (Read-Modify-Write)
    port->MODER &= ~(0x03U << shift);
    
    // 2. Escribe el nuevo modo
    port->MODER |= (static_cast<uint32_t>(mode) << shift);
    
    return true;
}

} // namespace HAL

int main() {
    // 1. Habilita el reloj para el puerto GPIOD (Bit 3 de RCC_AHB1ENR)
    *HAL::RCC_AHB1ENR |= (1U << 3);

    // 2. Configura el pin PD13 (LED azul en STM32F4-Discovery) como salida
    HAL::configure_pin_mode(HAL::GPIOD_PORT, 13, HAL::PinMode::Output);

    // 3. Enciende el LED poniendo PD13 a nivel alto mediante ODR o BSRR
    HAL::GPIOD_PORT->ODR |= (1U << 13);

    while (true) {
        // Bucle principal de tiempo real
    }

    return 0;
}