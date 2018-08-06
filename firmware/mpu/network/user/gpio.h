#ifndef _GPIO_H_
#define _GPIO_H_

#include <stdint.h>

#define RST_PIN    48   // PA16
#define DONE_PIN   49   // ?

#define OUT        1
#define IN         0

void gpio_init(uint32_t pin);
void gpio_direction(uint16_t pin, uint8_t direction);
void gpio_set_data(uint16_t pin, uint8_t data);
uint8_t gpio_get_data(uint16_t pin);






















#endif






