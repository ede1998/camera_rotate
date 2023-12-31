import json
import matplotlib.pyplot as plt
import numpy as np

with open('performance-hw-acc-stats-rotation.json', 'r') as hw_file, open('performance-sw-only-stats-rotation.json', 'r') as sw_file:
    hw = json.load(hw_file)
    sw = json.load(sw_file)

hw.sort(key=lambda k: int(k["Rotation"]))
sw.sort(key=lambda k: int(k["Rotation"]))

# Extract data for plotting
hw_rotations = [entry['Rotation'] for entry in hw]
hw_times = [entry['AverageTime'] for entry in hw]

sw_rotations = [entry['Rotation'] for entry in sw]
sw_times = [entry['AverageTime'] for entry in sw]

bar_width = 0.35
bar_positions1 = np.arange(len(hw_rotations))
bar_positions2 = bar_positions1 + bar_width

fig, ax = plt.subplots(figsize=(10, 6))
ax.bar(bar_positions1, hw_times, width=bar_width, label='Hardware Accelerated')
ax.bar(bar_positions2, sw_times, width=bar_width, label='Software Only')

ax.set_xticks(bar_positions1 + bar_width / 2)
ax.set_xticklabels(hw_rotations)
ax.set_xlabel('Rotation (deg)')
ax.set_ylabel('Time (μs)')
ax.legend()

plt.show()
