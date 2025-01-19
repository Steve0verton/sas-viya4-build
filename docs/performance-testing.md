# Performance Testing

## Hard Disk

Write Test
dd if=/dev/zero of=/path/to/disk/testfile bs=1M count=1024 oflag=direct

Read Test
dd if=/path/to/disk/testfile of=/dev/null bs=1M
