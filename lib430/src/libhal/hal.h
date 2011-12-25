#ifndef __HAL_H__
#define __HAL_H__
#include <stdint.h>

typedef HAL_MAP uint16_t;

/**
 * NoccyLabs Hardware Abstraction Library for the MSP430
 *
 * This library abstracts the actual hardware and pinouts required to perform
 * IO over SUART/UART/USCI/USI as well as regular GPIO. Very experimental but
 * the goal is to have a standardized way of passing around references to pins
 * and modules without really having to bother with where or what they are.
 */

enum hal_class {
	HAL_CLASS_NULL1 = 0x0100,
	HAL_CLASS_NULL2 = 0x0200,
	HAL_CLASS_NULL3 = 0x0400,
	HAL_CLASS_NULL4 = 0x0800,
	HAL_CLASS_USCI  = 0x1000,
	HAL_CLASS_USI   = 0x2000
	HAL_CLASS_GPIO  = 0x4000,
	HAL_CLASS_OTHER = 0x8000
};

enum hal_device {
	HAL_DEVICE_0    = 0x0010,
	HAL_DEVICE_1    = 0x0020,
	HAL_DEVICE_2    = 0x0030,
	HAL_DEVICE_3    = 0x0040
};

enum gpio_port {
	GPIO_PORT_0     = 0x0010,
	GPIO_PORT_1     = 0x0020,
	GPIO_PORT_2     = 0x0030,
	GPIO_PORT_3     = 0x0040
};

enum gpio_pin {
	GPIO_PIN_0      = 0x0001,
	GPIO_PIN_1      = 0x0002,
	GPIO_PIN_2      = 0x0003,
	GPIO_PIN_3      = 0x0004,
	GPIO_PIN_4      = 0x0005,
	GPIO_PIN_5      = 0x0006,
	GPIO_PIN_6      = 0x0007,
	GPIO_PIN_7      = 0x0008
};

inline void gpio_decode_port(HAL_MAP halmap) { return ((halmap & 0x00F0) >> 4); };
inline void gpio_decode_pin(HAL_MAP halmap) { return ((halmap & 0x000F); };

void gpio_makeinput(HAL_MAP pin);
void gpio_makeoutput(HAL_MAP pin);
void gpio_setstate(HAL_MAP pin, uint8_t state);

// HAL_MAP led = HAL_DEVICE_GPIO | GPIO_PORT_0 | GPIO_PIN_1;
// gpio_makeoutput(led); gpio_setstate(led, 1);

// gpio_setstate( HAL_DEVICE_GPIO | GPIO_PORT_0 | GPIO_PIN_0 , 1);

#endif // __HAL_H__