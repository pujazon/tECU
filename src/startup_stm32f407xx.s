.syntax unified
  .cpu cortex-m4
  .fpu softvfp
  .thumb

/* ============================================================================
 * Stack and Heap Configuration
 * ============================================================================ */
  .equ  Stack_Size, 0x00000400
  .section .stack
  .align 3
  .globl __initial_sp
  .globl Stack_Mem
Stack_Mem:
  .space Stack_Size
__initial_sp:

  .equ  Heap_Size, 0x00000200
  .section .heap
  .align 3
  .globl __heap_base
  .globl __heap_limit
  .globl Heap_Mem
__heap_base:
Heap_Mem:
  .space Heap_Size
__heap_limit:

/* ============================================================================
 * Vector Table
 * ============================================================================ */
  .section .isr_vector,"a",%progbits
  .type __Vectors, %object
  .size __Vectors, .-__Vectors

  .globl __Vectors
  .globl __Vectors_End
  .globl __Vectors_Size

__Vectors:
  .long  __initial_sp               /* Top of Stack */
  .long  Reset_Handler              /* Reset Handler */
  .long  NMI_Handler                /* NMI Handler */
  .long  HardFault_Handler          /* Hard Fault Handler */
  .long  MemManage_Handler          /* MPU Fault Handler */
  .long  BusFault_Handler           /* Bus Fault Handler */
  .long  UsageFault_Handler         /* Usage Fault Handler */
  .long  0                          /* Reserved */
  .long  0                          /* Reserved */
  .long  0                          /* Reserved */
  .long  0                          /* Reserved */
  .long  SVC_Handler                /* SVCall Handler */
  .long  DebugMon_Handler           /* Debug Monitor Handler */
  .long  0                          /* Reserved */
  .long  PendSV_Handler             /* PendSV Handler */
  .long  SysTick_Handler            /* SysTick Handler */

  /* External Interrupts */
  .long  WWDG_IRQHandler
  .long  PVD_IRQHandler
  .long  TAMP_STAMP_IRQHandler
  .long  RTC_WKUP_IRQHandler
  .long  FLASH_IRQHandler
  .long  RCC_IRQHandler
  .long  EXTI0_IRQHandler
  .long  EXTI1_IRQHandler
  .long  EXTI2_IRQHandler
  .long  EXTI3_IRQHandler
  .long  EXTI4_IRQHandler
  .long  DMA1_Stream0_IRQHandler
  .long  DMA1_Stream1_IRQHandler
  .long  DMA1_Stream2_IRQHandler
  .long  DMA1_Stream3_IRQHandler
  .long  DMA1_Stream4_IRQHandler
  .long  DMA1_Stream5_IRQHandler
  .long  DMA1_Stream6_IRQHandler
  .long  ADC_IRQHandler
  .long  CAN1_TX_IRQHandler
  .long  CAN1_RX0_IRQHandler
  .long  CAN1_RX1_IRQHandler
  .long  CAN1_SCE_IRQHandler
  .long  EXTI9_5_IRQHandler
  .long  TIM1_BRK_TIM9_IRQHandler
  .long  TIM1_UP_TIM10_IRQHandler
  .long  TIM1_TRG_COM_TIM11_IRQHandler
  .long  TIM1_CC_IRQHandler
  .long  TIM2_IRQHandler
  .long  TIM3_IRQHandler
  .long  TIM4_IRQHandler
  .long  I2C1_EV_IRQHandler
  .long  I2C1_ER_IRQHandler
  .long  I2C2_EV_IRQHandler
  .long  I2C2_ER_IRQHandler
  .long  SPI1_IRQHandler
  .long  SPI2_IRQHandler
  .long  USART1_IRQHandler
  .long  USART2_IRQHandler
  .long  USART3_IRQHandler
  .long  EXTI15_10_IRQHandler
  .long  RTC_Alarm_IRQHandler
  .long  OTG_FS_WKUP_IRQHandler
  .long  TIM8_BRK_TIM12_IRQHandler
  .long  TIM8_UP_TIM13_IRQHandler
  .long  TIM8_TRG_COM_TIM14_IRQHandler
  .long  TIM8_CC_IRQHandler
  .long  DMA1_Stream7_IRQHandler
  .long  FMC_IRQHandler
  .long  SDIO_IRQHandler
  .long  TIM5_IRQHandler
  .long  SPI3_IRQHandler
  .long  UART4_IRQHandler
  .long  UART5_IRQHandler
  .long  TIM6_DAC_IRQHandler
  .long  TIM7_IRQHandler
  .long  DMA2_Stream0_IRQHandler
  .long  DMA2_Stream1_IRQHandler
  .long  DMA2_Stream2_IRQHandler
  .long  DMA2_Stream3_IRQHandler
  .long  DMA2_Stream4_IRQHandler
  .long  ETH_IRQHandler
  .long  ETH_WKUP_IRQHandler
  .long  CAN2_TX_IRQHandler
  .long  CAN2_RX0_IRQHandler
  .long  CAN2_RX1_IRQHandler
  .long  CAN2_SCE_IRQHandler
  .long  OTG_FS_IRQHandler
  .long  DMA2_Stream5_IRQHandler
  .long  DMA2_Stream6_IRQHandler
  .long  DMA2_Stream7_IRQHandler
  .long  USART6_IRQHandler
  .long  I2C3_EV_IRQHandler
  .long  I2C3_ER_IRQHandler
  .long  OTG_HS_EP1_OUT_IRQHandler
  .long  OTG_HS_EP1_IN_IRQHandler
  .long  OTG_HS_WKUP_IRQHandler
  .long  OTG_HS_IRQHandler
  .long  DCMI_IRQHandler
  .long  0
  .long  HASH_RNG_IRQHandler
  .long  FPU_IRQHandler

__Vectors_End:
  .equ __Vectors_Size, __Vectors_End - __Vectors

/* ============================================================================
 * Reset Code and Exception Handlers
 * ============================================================================ */
  .section .text.Reset_Handler
  .weak Reset_Handler
  .type Reset_Handler, %function
Reset_Handler:
  ldr   sp, =__initial_sp
  ldr   r0, =SystemInit
  blx   r0
  ldr   r0, =main
  bx    r0
  .size Reset_Handler, .-Reset_Handler

/* Default Handler for Unhandled Interrupts */
  .section .text.Default_Handler,"ax",%progbits
  .global Default_Handler
  .type Default_Handler, %function
Default_Handler:
Infinite_Loop:
  b     Infinite_Loop
  .size Default_Handler, .-Default_Handler

/* Macro to Declare Weak Interrupt Handlers Mapping to Default_Handler */
  .macro def_irq_handler handler_name
  .weak  \handler_name
  .set   \handler_name, Default_Handler
  .endm

  def_irq_handler NMI_Handler
  def_irq_handler HardFault_Handler
  def_irq_handler MemManage_Handler
  def_irq_handler BusFault_Handler
  def_irq_handler UsageFault_Handler
  def_irq_handler SVC_Handler
  def_irq_handler DebugMon_Handler
  def_irq_handler PendSV_Handler
  def_irq_handler SysTick_Handler

  def_irq_handler WWDG_IRQHandler
  def_irq_handler PVD_IRQHandler
  def_irq_handler TAMP_STAMP_IRQHandler
  def_irq_handler RTC_WKUP_IRQHandler
  def_irq_handler FLASH_IRQHandler
  def_irq_handler RCC_IRQHandler
  def_irq_handler EXTI0_IRQHandler
  def_irq_handler EXTI1_IRQHandler
  def_irq_handler EXTI2_IRQHandler
  def_irq_handler EXTI3_IRQHandler
  def_irq_handler EXTI4_IRQHandler
  def_irq_handler DMA1_Stream0_IRQHandler
  def_irq_handler DMA1_Stream1_IRQHandler
  def_irq_handler DMA1_Stream2_IRQHandler
  def_irq_handler DMA1_Stream3_IRQHandler
  def_irq_handler DMA1_Stream4_IRQHandler
  def_irq_handler DMA1_Stream5_IRQHandler
  def_irq_handler DMA1_Stream6_IRQHandler
  def_irq_handler ADC_IRQHandler
  def_irq_handler CAN1_TX_IRQHandler
  def_irq_handler CAN1_RX0_IRQHandler
  def_irq_handler CAN1_RX1_IRQHandler
  def_irq_handler CAN1_SCE_IRQHandler
  def_irq_handler EXTI9_5_IRQHandler
  def_irq_handler TIM1_BRK_TIM9_IRQHandler
  def_irq_handler TIM1_UP_TIM10_IRQHandler
  def_irq_handler TIM1_TRG_COM_TIM11_IRQHandler
  def_irq_handler TIM1_CC_IRQHandler
  def_irq_handler TIM2_IRQHandler
  def_irq_handler TIM3_IRQHandler
  def_irq_handler TIM4_IRQHandler
  def_irq_handler I2C1_EV_IRQHandler
  def_irq_handler I2C1_ER_IRQHandler
  def_irq_handler I2C2_EV_IRQHandler
  def_irq_handler I2C2_ER_IRQHandler
  def_irq_handler SPI1_IRQHandler
  def_irq_handler SPI2_IRQHandler
  def_irq_handler USART1_IRQHandler
  def_irq_handler USART2_IRQHandler
  def_irq_handler USART3_IRQHandler
  def_irq_handler EXTI15_10_IRQHandler
  def_irq_handler RTC_Alarm_IRQHandler
  def_irq_handler OTG_FS_WKUP_IRQHandler
  def_irq_handler TIM8_BRK_TIM12_IRQHandler
  def_irq_handler TIM8_UP_TIM13_IRQHandler
  def_irq_handler TIM8_TRG_COM_TIM14_IRQHandler
  def_irq_handler TIM8_CC_IRQHandler
  def_irq_handler DMA1_Stream7_IRQHandler
  def_irq_handler FMC_IRQHandler
  def_irq_handler SDIO_IRQHandler
  def_irq_handler TIM5_IRQHandler
  def_irq_handler SPI3_IRQHandler
  def_irq_handler UART4_IRQHandler
  def_irq_handler UART5_IRQHandler
  def_irq_handler TIM6_DAC_IRQHandler
  def_irq_handler TIM7_IRQHandler
  def_irq_handler DMA2_Stream0_IRQHandler
  def_irq_handler DMA2_Stream1_IRQHandler
  def_irq_handler DMA2_Stream2_IRQHandler
  def_irq_handler DMA2_Stream3_IRQHandler
  def_irq_handler DMA2_Stream4_IRQHandler
  def_irq_handler ETH_IRQHandler
  def_irq_handler ETH_WKUP_IRQHandler
  def_irq_handler CAN2_TX_IRQHandler
  def_irq_handler CAN2_RX0_IRQHandler
  def_irq_handler CAN2_RX1_IRQHandler
  def_irq_handler CAN2_SCE_IRQHandler
  def_irq_handler OTG_FS_IRQHandler
  def_irq_handler DMA2_Stream5_IRQHandler
  def_irq_handler DMA2_Stream6_IRQHandler
  def_irq_handler DMA2_Stream7_IRQHandler
  def_irq_handler USART6_IRQHandler
  def_irq_handler I2C3_EV_IRQHandler
  def_irq_handler I2C3_ER_IRQHandler
  def_irq_handler OTG_HS_EP1_OUT_IRQHandler
  def_irq_handler OTG_HS_EP1_IN_IRQHandler
  def_irq_handler OTG_HS_WKUP_IRQHandler
  def_irq_handler OTG_HS_IRQHandler
  def_irq_handler DCMI_IRQHandler
  def_irq_handler HASH_RNG_IRQHandler
  def_irq_handler FPU_IRQHandler

/* ============================================================================
 * Optional C Library (Newlib) Stack and Heap Initializer
 * ============================================================================ */
  .section .text.__user_initial_stackheap,"ax",%progbits
  .global __user_initial_stackheap
  .type __user_initial_stackheap, %function
__user_initial_stackheap:
  ldr   r0, =Heap_Mem
  ldr   r1, =(Stack_Mem + Stack_Size)
  ldr   r2, =(Heap_Mem + Heap_Size)
  ldr   r3, =Stack_Mem
  bx    lr
  .size __user_initial_stackheap, . - __user_initial_stackheap

  .end
