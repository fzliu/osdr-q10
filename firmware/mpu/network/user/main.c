#include "main.h"
#include "fpga.h"
#include "udp.h"
#include "tcp.h"

int msg_cmd;
char ip_str[20];

bool use_tcp = false;
bool verbose = false;
bool rssi = false;

int main(int argc, char **argv)
{
  fpga_init();
  fpga_enable();
  fpga_rst();
  fpga_test();
}
