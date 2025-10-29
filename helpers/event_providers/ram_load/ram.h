#include <mach/mach.h>
#include <mach/vm_statistics.h>
#include <sys/sysctl.h>
#include <stdbool.h>
#include <unistd.h>
#include <stdio.h>

struct ram {
  host_t host;
  vm_size_t page_size;
  vm_statistics64_data_t vm_stat;
  mach_msg_type_number_t count;

  uint64_t total_memory;
  uint64_t used_memory;
  uint64_t free_memory;
  int usage_percentage;
};

static inline void ram_init(struct ram* ram) {
  ram->host = mach_host_self();
  ram->count = HOST_VM_INFO64_COUNT;

  // Get page size
  host_page_size(ram->host, &ram->page_size);

  // Get total physical memory
  int mib[2] = {CTL_HW, HW_MEMSIZE};
  size_t size = sizeof(ram->total_memory);
  sysctl(mib, 2, &ram->total_memory, &size, NULL, 0);
}

static inline void ram_update(struct ram* ram) {
  kern_return_t error = host_statistics64(ram->host,
                                          HOST_VM_INFO64,
                                          (host_info64_t)&ram->vm_stat,
                                          &ram->count);

  if (error != KERN_SUCCESS) {
    printf("Error: Could not read VM statistics.\n");
    return;
  }

  // Calculate memory usage
  uint64_t free_pages = ram->vm_stat.free_count;
  uint64_t active_pages = ram->vm_stat.active_count;
  uint64_t inactive_pages = ram->vm_stat.inactive_count;
  uint64_t wire_pages = ram->vm_stat.wire_count;
  uint64_t compressed_pages = ram->vm_stat.compressor_page_count;

  ram->free_memory = free_pages * ram->page_size;
  ram->used_memory = (active_pages + inactive_pages + wire_pages + compressed_pages) * ram->page_size;

  ram->usage_percentage = (double)ram->used_memory / (double)ram->total_memory * 100.0;
}