import pandas as pd
import matplotlib.pyplot as plt
import subprocess

def get_gpu_name():
    return subprocess.check_output(["nvidia-smi", "--query-gpu=name", "--format=csv,noheader"]).decode('utf-8').strip()

def read_memory_reports(gpu_name):
    unified_memory_df = pd.read_csv(f'nsys_outputs/{gpu_name}/unified_memory_report_cuda_gpu_kern_sum.csv')
    explicit_memory_df = pd.read_csv(f'nsys_outputs/{gpu_name}/explicit_memory_report_cuda_gpu_kern_sum.csv')
    return unified_memory_df, explicit_memory_df

def extract_avg_time(memory_df, kernel_name):
    return memory_df.loc[memory_df['Name'] == kernel_name, 'Avg (ns)'].values[0] / 1_000_000  # Convert to milliseconds

def plot_avg_times(gpu_name, unified_avg_time_ms, explicit_avg_time_ms):
    labels = ['Unified Memory', 'Explicit Memory']
    avg_times = [unified_avg_time_ms, explicit_avg_time_ms]
    
    bars = plt.bar(labels, avg_times, color=['orange', 'blue'], width=0.4)
    plt.ylabel('Average Time (ms)')
    plt.title('Comparison of addVectorsInto Kernel Execution Average Time')
    plt.ylim(0, max(avg_times) * 1.1)
    plt.tight_layout()
    
    # Add legend
    plt.legend(bars, labels, title="Memory Type")
    
    plt.savefig(f'{gpu_name}_unified-vs-explicit.jpg')

# Main execution
GPU_NAME = get_gpu_name()
unified_memory_df, explicit_memory_df = read_memory_reports(GPU_NAME)
unified_avg_time_ms = extract_avg_time(unified_memory_df, 'addVectorsInto(float *, float *, float *, int)')
explicit_avg_time_ms = extract_avg_time(explicit_memory_df, 'addVectorsInto(float *, float *, float *, int)')

print(f'Unified Memory: {unified_avg_time_ms} ms')
print(f'Explicit Memory: {explicit_avg_time_ms} ms')

plot_avg_times(GPU_NAME, unified_avg_time_ms, explicit_avg_time_ms)
