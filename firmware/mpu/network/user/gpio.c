#include <fcntl.h>   
#include <linux/fb.h>   
#include <sys/mman.h>   
#include <sys/ioctl.h> 

#include <pthread.h>
#include <sys/types.h> 
#include <sys/socket.h> 
#include <unistd.h> 
#include <netinet/in.h> 
#include <arpa/inet.h> 
#include <stdio.h> 
#include <stdlib.h> 
#include <errno.h> 
#include <netdb.h> 
#include <stdarg.h> 
#include <string.h> 
#include <sys/msg.h>

#include "gpio.h"


void gpio_init(uint32_t pin)
{
	int fd, len;
	char buf[11];
	int ret;

	fd = open("/sys/class/gpio/export", O_WRONLY);
	if (fd < 0) {
		printf("%s: Can't export GPIO\n\r", __func__);
		return;
	}
	
	len = snprintf(buf, sizeof(buf), "%d", pin);
	ret = write(fd, buf, len);
	if (ret == -1) {
		// Unused variable - fix compiler warning
	}

	close(fd);
}

void gpio_direction(uint16_t pin, uint8_t direction)
{
	int fd;
	char buf[60];
	int ret;

	snprintf(buf, sizeof(buf), "/sys/class/gpio/gpio%d/direction", pin);

	fd = open(buf, O_WRONLY);
	if (fd < 0) {
		printf("%s: Can't set GPIO direction\n\r", __func__);
		return;
	}

	if (direction == 1)
		ret = write(fd, "out", 4);
	else
		ret = write(fd, "in", 3);
	if (ret == -1) {
		// Unused variable - fix compiler warning
	}

	close(fd);
}

void gpio_set_data(uint16_t pin, uint8_t data)
{
	int fd;
	char buf[60];
	int ret;

	snprintf(buf, sizeof(buf), "/sys/class/gpio/gpio%d/value", pin);

	fd = open(buf, O_WRONLY);
	if (fd < 0) {
		printf("%s: Can't set GPIO value\n\r", __func__);
		return;
	}

	if (data)
		ret = write(fd, "1", 2);
	else
		ret = write(fd, "0", 2);
	if (ret == -1) {
		// Unused variable - fix compiler warning
	}

	close(fd);
}

uint8_t gpio_get_data(uint16_t pin)
{
	int fd;
	char buf[60];
	char data[5];

	snprintf(buf, sizeof(buf), "/sys/class/gpio/gpio%d/value", pin);

	fd = open(buf, O_WRONLY);
	if (fd < 0) {
		printf("%s: Can't set GPIO value\n\r", __func__);
		return;
	}

	read(fd, data, sizeof(data));

	close(fd);

	return (data[0] - '0');
}


