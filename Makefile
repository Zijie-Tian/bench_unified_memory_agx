CUDA_SOURCES = vector-add-explicit-memory.cu vector-add-unified-memory.cu
CUDA_OBJECTS = $(CUDA_SOURCES:.cu=.o)

# Compiler and flags
NVCC = nvcc
NVCC_FLAGS = -arch=sm_80 -O3

# Target executables
TARGETS = explicit_memory unified_memory explicit_memory_debug unified_memory_debug

# Build rules
all: $(TARGETS)

explicit_memory: vector-add-explicit-memory.o
	$(NVCC) $(NVCC_FLAGS) -o $@ $<

unified_memory: vector-add-unified-memory.o
	$(NVCC) $(NVCC_FLAGS) -o $@ $<

debug: NVCC_FLAGS = -arch=sm_80 -g -O0
debug: vector-add-explicit-memory.o vector-add-unified-memory.o
	$(NVCC) $(NVCC_FLAGS) -o explicit_memory_debug vector-add-explicit-memory.o
	$(NVCC) $(NVCC_FLAGS) -o unified_memory_debug vector-add-unified-memory.o

%.o: %.cu
	$(NVCC) $(NVCC_FLAGS) -c $< -o $@

clean:
	rm -f $(TARGETS) $(CUDA_OBJECTS)

.PHONY: all clean
