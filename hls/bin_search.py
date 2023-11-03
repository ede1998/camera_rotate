import subprocess

def find_and_replace(file_path, old_line_start, new_number):
    with open(file_path, 'r') as file:
        lines = file.readlines()

    found = False
    for i, line in enumerate(lines):
        if line.strip().startswith(old_line_start):
            lines[i] = f"{old_line_start}{new_number};\n"

            found = True

    if found:
        with open(file_path, 'w') as file:
            file.writelines(lines)
    else:
        assert False, "failed to edit file"

file_path = "src/krnl_vadd.h"
lower = 514    # Minimum possible value
upper = 800  # Maximum possible value
while lower < upper:
    mid = (lower + upper) // 2
    find_and_replace(file_path, "static constexpr uint64_t MAX_ROWS = ", mid)
    find_and_replace(file_path, "static constexpr uint64_t MAX_COLS = ", mid)

    commands = ["bash", "-c", "export DISPLAY=:10.0; source ../setup.sh; vitis_hls run_hls.tcl;"]
    # Execute the process
    process = subprocess.Popen(commands, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    process.communicate()  # Wait for the process to finish

    if process.returncode == 0:
        print(f"Success with {mid}")
        lower = mid
    else:
        print(f"Failure with {mid}")
        upper = mid

print(f"Finished with {mid}")
