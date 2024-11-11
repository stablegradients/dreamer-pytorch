#!/bin/bash
export MUJOCO_GL=egl

# Array of DMC tasks
declare -a tasks=(
  "acrobot_swingup"
  "cartpole_balance"
  "cartpole_balance_sparse"
  "cartpole_swingup"
  "cartpole_swingup_sparse"
  "cheetah_run"
  "cup_catch"
  "finger_spin"
  "finger_turn_easy"
  "finger_turn_hard"
  "hopper_hop"
  "hopper_stand"
  "pendulum_swingup"
  "quadruped_run"
  "quadruped_walk"
  "reacher_easy"
  "reacher_hard"
  "walker_run"
  "walker_stand"
  "walker_walk"
)

# Detect the actual number of GPUs
num_gpus=$(nvidia-smi -L | wc -l)
runs_per_gpu=1  # Adjust as needed
total_runs=${#tasks[@]}

# Directory to store logs
log_dir="./logs/dmc"
mkdir -p $log_dir

# Loop through tasks and start experiments
for ((i=0; i < total_runs; i++)); do
  gpu_id=$((i % num_gpus))
  task=${tasks[$i]}
  domain=$(echo $task | cut -d'_' -f1)
  task_name=$(echo $task | cut -d'_' -f2-)

  echo "Running task $task on GPU $gpu_id..."
  python main_dmc.py --cuda-idx $gpu_id --game "$task" --log-dir "$log_dir/$task" &

  # Wait if we hit the maximum concurrent runs
  if (( (i + 1) % (num_gpus * runs_per_gpu) == 0 )); then
    wait
  fi
done

wait
echo "All tasks complete."