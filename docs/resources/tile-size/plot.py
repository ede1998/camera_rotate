import json
import matplotlib.pyplot as plt
import numpy as np

with open('stats.json', 'r') as file:
    data = json.load(file)[1:]

tile_sizes = [entry['tile_size'] for entry in data]
avg_lat_values = [entry['avg_lat'] for entry in data]
max_lat_values = [entry['max_lat'] for entry in data]
min_lat_values = [entry['min_lat'] for entry in data]

bar_width = 0.3
bar_positions1 = np.arange(len(tile_sizes))
bar_positions2 = bar_positions1 + bar_width
bar_positions3 = bar_positions2 + bar_width

fig, ax = plt.subplots(figsize=(12, 8))

# Latency Metrics
ax.bar(bar_positions1, min_lat_values, width=bar_width, label='Minimum')
ax.bar(bar_positions2, avg_lat_values, width=bar_width, label='Durchschnitt')
ax.bar(bar_positions3, max_lat_values, width=bar_width, label='Maximum')

ax.set_xticks(bar_positions2)
ax.set_xticklabels(tile_sizes)
ax.set_xlabel('Tile Size')
ax.set_ylabel('Latenz')
ax.legend()

# plt.title('Metrics by Tile Size')
plt.show()


bram_values = [entry['bram'] for entry in data]
lut_values = [entry['lut'] for entry in data]
ff_values = [entry['ff'] for entry in data]
dsp_values = [entry['dsp'] for entry in data]

# Set up the bar positions
bar_width = 0.7
bar_positions1 = np.arange(len(tile_sizes))

# Plotting subplots
fig, axs = plt.subplots(1, 4, figsize=(12, 4), sharex=True)

# BRAM
axs[0].bar(bar_positions1, bram_values, width=bar_width, label='BRAM')
axs[0].set_title('BRAM')
axs[0].set_ylabel('Resource Utilization')

# LUT
axs[1].bar(bar_positions1, lut_values, width=bar_width, label='LUT')
axs[1].set_title('LUT')

# FF
axs[2].bar(bar_positions1, ff_values, width=bar_width, label='FF')
axs[2].set_title('FF')

# DSP
axs[3].bar(bar_positions1, dsp_values, width=bar_width, label='DSP')
axs[3].set_title('DSP')

# Set common labels
for ax in axs.flat:
    ax.set_xticks(bar_positions1 + bar_width / 2)
    ax.set_xticklabels(tile_sizes)

# Adjust layout
plt.tight_layout()
plt.show()