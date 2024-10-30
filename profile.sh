#! /bin/zsh

# Get the GPU device name
GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader)

# Create a directory for the GPU device name under nsys_outputs
mkdir -p "nsys_outputs/$GPU_NAME"

# Remove all files in the GPU-specific output directory
rm -rf "nsys_outputs/$GPU_NAME/*"

make clean
make all

# Test for Unified Memory
nsys profile --output="nsys_outputs/$GPU_NAME/unified_memory_report" \
    --trace=cuda \
    ./unified_memory

# Test for Explicit Memory
nsys profile --output="nsys_outputs/$GPU_NAME/explicit_memory_report" \
    --trace=cuda \
    ./explicit_memory

# Convert to .stat format
nsys stats -r cuda_gpu_kern_sum "nsys_outputs/$GPU_NAME/unified_memory_report.nsys-rep" -o "nsys_outputs/$GPU_NAME/unified_memory_report"
nsys stats -r cuda_gpu_kern_sum "nsys_outputs/$GPU_NAME/explicit_memory_report.nsys-rep" -o "nsys_outputs/$GPU_NAME/explicit_memory_report"

# Remove all files except those ending with .csv in the GPU-specific output directory
find "nsys_outputs/$GPU_NAME" -type f ! -name '*.csv' -exec rm {} +
