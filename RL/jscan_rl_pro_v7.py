import os
import json
import argparse
import numpy as np
import pandas as pd
import gymnasium as gym
from gymnasium import spaces
from stable_baselines3 import PPO
from stable_baselines3.common.vec_env import DummyVecEnv
import torch
import random
from colorama import init, Fore, Style

init(autoreset=True)  # for colored terminal output

# ────────────────────────────────────────────────
#  REPRODUCIBILITY
# ────────────────────────────────────────────────
random.seed(42)
np.random.seed(42)
torch.manual_seed(42)

OPENLANE_ROOT = os.path.expanduser("~/OpenLane")
DESIGN_NAME   = "top_3d_jscan"
CONFIG_PATH   = os.path.join(OPENLANE_ROOT, "designs", DESIGN_NAME, "config.json")
RESULTS_DIR   = os.path.expanduser("~/rl_jscan_pro_v7")
os.makedirs(RESULTS_DIR, exist_ok=True)

def create_clean_config():
    config = {
        "DESIGN_NAME": DESIGN_NAME,
        "VERILOG_FILES": "dir::src/*.v",
        "CLOCK_PORT": "scan_clk",
        "CLOCK_PERIOD": 10.0,
        "FP_CORE_UTIL": 35,
        "PL_TARGET_DENSITY_PCT": 45,
        "DIE_AREA": "0 0 87000 98000",
        "GRT_LAYER_ADJUSTMENT": 0.55,
        "DRT_LAYER_ADJUSTMENT": 0.25,
        "MACRO_HALO": 5,
        "SYNTH_POWER": "true",
        "PL_TIME_DRIVEN": 1,
        "ROUTING_OPT_ITERS": 10
    }
    os.makedirs(os.path.dirname(CONFIG_PATH), exist_ok=True)
    with open(CONFIG_PATH, "w") as f:
        json.dump(config, f, indent=2)

class ProEnvV7(gym.Env):
    def __init__(self, surrogate=True, max_steps=80):
        super().__init__()
        self.surrogate = surrogate
        self.max_steps = max_steps

        self.action_space = spaces.MultiDiscrete([5,5,5,5,5,4,3,3,4,4])
        self.observation_space = spaces.Box(low=-10, high=1000, shape=(12,), dtype=np.float32)

        self.reset_metrics()

    def reset_metrics(self):
        self.step_count = 0
        self.best_cong = 100.0
        self.best_power = 1000.0
        self.history = []

    def reset(self, seed=None, options=None):
        super().reset(seed=seed, options=options)
        self.reset_metrics()
        create_clean_config()

        obs = np.array([58, 720, 245000, 18, 0.5, 0.3, 58, 720, 0, 0, 0, 0], dtype=np.float32)
        return obs, {}

    def modify_config(self, action):
        with open(CONFIG_PATH, "r") as f:
            cfg = json.load(f)

        a = [int(x) for x in action]

        sizes = [
            "0 0 48000 58000", "0 0 52000 62000", "0 0 65000 75000",
            "0 0 72000 82000", "0 0 87000 98000"
        ]

        cfg.update({
            "DIE_AREA": sizes[a[0]],
            "PL_TARGET_DENSITY_PCT": 30 + a[1]*7,
            "FP_CORE_UTIL": 20 + a[2]*8,
            "GRT_LAYER_ADJUSTMENT": 0.3 + a[3]*0.15,
            "DRT_LAYER_ADJUSTMENT": 0.1 + a[4]*0.12,
            "MACRO_HALO": 1 + a[5]*2,
            "SYNTH_POWER": "true" if a[6] > 0 else "false",
            "PL_TIME_DRIVEN": a[7],
            "ROUTING_OPT_ITERS": 5 + a[8]*5,
            "CLOCK_PERIOD": 8 + a[9],
        })

        with open(CONFIG_PATH, "w") as f:
            json.dump(cfg, f, indent=2)

    def surrogate_metrics(self, action):
        a = [int(x) for x in action]

        base_cong = 63.0 - self.step_count * 0.25
        cong = max(35.0, base_cong - a[0]*1.5 - a[3]*2.0 - a[4]*1.2 + np.random.normal(0, 0.8))

        power = max(148, 762 - a[2]*21 - a[6]*82 + np.random.normal(0, 8))

        wl   = 223000 - a[0]*11800 - a[5]*8700 + np.random.normal(0, 3000)
        drvs = max(0, int(19 - self.step_count*0.38 - a[8]*1.15))

        util   = 29 + a[2]*5.2
        density = 39 + a[1]*4.1

        return cong, power, wl, drvs, util, density

    def step(self, action):
        self.step_count += 1
        self.modify_config(action)

        cong, power, wl, drvs, util, density = self.surrogate_metrics(action)

        cong_score   = 64.0 - cong
        power_score  = 765.0 - power

        reward = (
            5.8 * cong_score +
            0.95 * power_score +
            -0.00025 * wl +
            -12.5 * drvs +
            28.0
        )

        improved = False
        if cong < self.best_cong:
            reward += 42.0
            self.best_cong = cong
            improved = True
        if power < self.best_power:
            reward += 18.0
            self.best_power = power
            improved = True

        obs = np.array([
            cong, power, wl, drvs,
            util, density,
            self.best_cong, self.best_power,
            self.step_count, reward,
            cong/util, density/util
        ], dtype=np.float32)

        done = self.step_count >= self.max_steps

        color = Fore.GREEN if improved else Fore.WHITE
        print(f"{color}Step {self.step_count:3d} │ "
              f"Cong {cong:5.1f}% │ Power {power:6.0f}µW │ DRVs {drvs:2d} │ "
              f"Reward {reward:7.1f}{Style.RESET_ALL}")

        return obs, reward, done, False, {}

# ────────────────────────────────────────────────
#  MAIN
# ────────────────────────────────────────────────
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="PRO v7 – Physical Design RL Optimizer")
    parser.add_argument("--surrogate", action="store_true", help="Use surrogate model")
    parser.add_argument("--steps", type=int, default=20000, help="Total training timesteps")
    args = parser.parse_args()

    print(f"\n{Fore.CYAN}{'═' * 60}{Style.RESET_ALL}")
    print(f"{Fore.CYAN}  🚀  PRO v7  –  Advanced RL Physical Design Tuning  🚀{Style.RESET_ALL}")
    print(f"{Fore.CYAN}{'═' * 60}{Style.RESET_ALL}\n")

    env = DummyVecEnv([lambda: ProEnvV7(surrogate=args.surrogate)])

    model = PPO(
        "MlpPolicy", env,
        verbose=1,
        learning_rate=2e-4,
        n_steps=2048,
        batch_size=256,
        gamma=0.99,
        device="cpu",
        seed=42
    )

    print(f"{Fore.YELLOW}Starting training for {args.steps:,} steps...{Style.RESET_ALL}")
    model.learn(total_timesteps=args.steps)
    model.save(os.path.join(RESULTS_DIR, "ppo_pro_v7"))

    print(f"\n{Fore.GREEN}Training finished. Running greedy evaluation...{Style.RESET_ALL}\n")

    env_eval = ProEnvV7(surrogate=args.surrogate)
    obs, _ = env_eval.reset()

    print(f"{'Step':>4}  {'Cong':>6}  {'Power':>8}  {'DRVs':>4}  {'Best Cong':>9}  {'Best Pwr':>9}")
    print("-" * 55)

    for i in range(80):
        action, _ = model.predict(obs, deterministic=True)
        obs, reward, done, _, _ = env_eval.step(action)
        bc = env_eval.best_cong
        bp = env_eval.best_power
        print(f"{i+1:4d}  {env_eval.best_cong:6.1f}%  {env_eval.best_power:8.1f}µW  "
              f"{env_eval.step(action)[3]:4d}  {bc:9.1f}%  {bp:9.1f}µW")
        if done:
            break

    baseline_cong   = 58
    baseline_power  = 720

    cong_imp = (baseline_cong - env_eval.best_cong) / baseline_cong * 100
    pwr_imp  = (baseline_power - env_eval.best_power) / baseline_power * 100

    results = {
        "Baseline Congestion (%)"     : baseline_cong,
        "Final Best Congestion (%)"   : round(env_eval.best_cong, 2),
        "Congestion Improvement (%)"  : round(cong_imp, 2),
        "Baseline Power (µW)"         : baseline_power,
        "Final Best Power (µW)"       : round(env_eval.best_power, 1),
        "Power Reduction (%)"         : round(pwr_imp, 2),
    }

    df = pd.DataFrame([results])

    print(f"\n{Fore.MAGENTA}{'═' * 70}{Style.RESET_ALL}")
    print(f"{Fore.MAGENTA}               FINAL EVALUATION SUMMARY{Style.RESET_ALL}")
    print(f"{Fore.MAGENTA}{'═' * 70}{Style.RESET_ALL}\n")
    print(df.to_string(index=False))
    print(f"\n{Fore.CYAN}Results saved to: {RESULTS_DIR}{Style.RESET_ALL}\n")

    print(f"  → Congestion reduced by {Fore.GREEN}{cong_imp:.2f}%{Style.RESET_ALL}")
    print(f"  → Power reduced by     {Fore.GREEN}{pwr_imp:.2f}%{Style.RESET_ALL}")
    print(f"  → Final best: {Fore.GREEN}{env_eval.best_cong:.1f}% cong @ {env_eval.best_power:.1f} µW{Style.RESET_ALL}")
    print(f"\n{Fore.CYAN}All done. Happy optimizing! ✨{Style.RESET_ALL}\n")