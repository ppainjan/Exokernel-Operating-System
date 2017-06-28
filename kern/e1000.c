#include <kern/e1000.h>

// LAB 6: Your driver code here

struct e1000_tx_desc tx_desc_buf[TXRING_LEN] __attribute__ ((aligned (PGSIZE)));
struct e1000_data tx_data_buf[TXRING_LEN] __attribute__ ((aligned (PGSIZE)));

static void init_desc() {
	int i;
	for (i = 0; i < TXRING_LEN; i++)
	{
		tx_desc_buf[i].buffer_addr = PADDR(&tx_data_buf[i]);
		tx_desc_buf[i].upper.fields.status = E1000_TXD_STAT_DD;
	}
}

static void e1000_init() {
	e1000[E1000_TDBAL] = PADDR(tx_desc_buf);
	e1000[E1000_TDBAH] = 0x0;
	e1000[E1000_TDH] = 0x0;
	e1000[E1000_TDT] = 0x0;
	e1000[E1000_TDLEN] = TXRING_LEN * sizeof(struct e1000_tx_desc);
	e1000[E1000_TCTL] = VALUEATMASK(1, E1000_TCTL_EN) | VALUEATMASK(1, E1000_TCTL_PSP) | VALUEATMASK(0x10, E1000_TCTL_CT)
	| VALUEATMASK(0x40,E1000_TCTL_COLD);
	e1000[E1000_TIPG] = VALUEATMASK(10, E1000_TIPG_IPGT) | VALUEATMASK(8, E1000_TIPG_IPGR1) | VALUEATMASK(6, E1000_TIPG_IPGR2);
	
}
int e1000_attach(struct pci_func *pcif) {
	pci_func_enable(pcif); // enable PCI function
	e1000 = mmio_map_region(pcif->reg_base[0], pcif->reg_size[0]); // create virtual memory mapping
 	assert(e1000[E1000_STATUS] == 0x80080783);
 	//cprintf("E1000 status: %08x\n", e1000[E1000_STATUS]);
 	e1000_init();
 	init_desc();
 	return 0;
}

int e1000_xmit(uint8_t * addr, size_t length) {
	uint32_t tail = e1000[E1000_TDT];
	struct e1000_tx_desc * tail_desc = &tx_desc_buf[tail];
	if (tail_desc->upper.fields.status != E1000_TXD_STAT_DD)
	{
		return -1;
	}
	length = length >  DATA_SIZE ?  DATA_SIZE : length;
	memmove(&tx_data_buf[tail], addr, length);
	tail_desc->lower.flags.length = length;
	tail_desc->upper.fields.status = 0;
	tail_desc->lower.data |=  (E1000_TXD_CMD_RS | E1000_TXD_CMD_EOP);
	e1000[E1000_TDT] = (tail + 1) % TXRING_LEN;
	
	return 0;
}
