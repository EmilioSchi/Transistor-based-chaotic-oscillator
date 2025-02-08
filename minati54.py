import numpy as np
import matplotlib.pyplot as plt

# Use double precision
dtype = np.float64

# Time parameters
DT = dtype(1e-6)
T  = dtype(10.0)
STEPS = int(np.round(T / DT))

# Nonlinear device parameters
IS       = dtype(1.0e-14)
VT       = dtype(0.0259)
DROP     = dtype(0.1)
BETA_F   = dtype(145.76)
BETA_R   = dtype(0.1001)

# Precompute frequently used ratios
IS_over_BETA_F = dtype(IS / BETA_F)
IS_over_BETA_R = dtype(IS / BETA_R)
INV_VT         = dtype(1.0 / VT)

# A shift used in i_l3 update (if desired as constant)
SHIFT = dtype(0.15)

# Component values
VCC, R, L1, L2, L3, C, C1, C2, C3 = map(dtype, [5.0, 226.0, 150.0, 68.0, 15.0, 470e-6, 30e-6, 30e-6, 1e-8])

# Inversions (1 / values)
INV_C, INV_C1, INV_C2, INV_C3, INV_L1, INV_L2, INV_L3 = map(lambda x: dtype(1.0 / x), [C, C1, C2, C3, L1, L2, L3])

def euler(value, derivative):
    """
    One step of the Euler method: next_value = value + derivative*DT
    """
    return value + derivative * DT

def i_e(v_be, v_bc):
    """
    Emitter current for BJT transistor model.
    We reuse precomputed: IS, DROP, INV_VT, IS_over_BETA_F, etc.
    """
    # Common term
    tmp = IS * (np.exp((v_be - DROP) * INV_VT) - np.exp((v_bc - DROP) * INV_VT))
    if v_be > dtype(0.0):
        # Forward conduction includes base current factor
        return IS_over_BETA_F * np.exp((v_be - DROP) * INV_VT) + tmp
    else:
        # If v_be <= 0, no forward base current contribution
        return tmp

def i_c(v_be, v_bc):
    """
    Collector current for BJT transistor model.
    """
    # Common term
    tmp = IS * (np.exp((v_be - DROP) * INV_VT) - np.exp((v_bc - DROP) * INV_VT))
    if v_bc > dtype(0.0):
        # Reverse conduction includes base current factor
        return -IS_over_BETA_R * np.exp((v_bc - DROP) * INV_VT) + tmp
    else:
        return tmp

def i_b(v_be, v_bc):
    """
    Base current for BJT transistor model.
    """
    both_positive = (v_be > dtype(0.0)) and (v_bc > dtype(0.0))
    if both_positive:
        return (IS_over_BETA_F * np.exp((v_be - DROP) * INV_VT) +
                IS_over_BETA_R * np.exp((v_bc - DROP) * INV_VT))
    elif v_be > dtype(0.0):
        return IS_over_BETA_F * np.exp((v_be - DROP) * INV_VT)
    elif v_bc > dtype(0.0):
        return IS_over_BETA_R * np.exp((v_bc - DROP) * INV_VT)
    else:
        return dtype(0.0)

v_c  = dtype(0.76)
v_1  = dtype(50e-6)
v_2  = dtype(1e-8)
v_3  = dtype(10e-8)
i_l1 = dtype(2e-4)
i_l2 = dtype(-2e-4)
i_l3 = dtype(2e-4)

record_interval = 1000
time_hist, v_c_hist, v_1_hist, v_2_hist, v_3_hist, i_l1_hist, i_l2_hist, i_l3_hist = (
    [] for _ in range(8)
)

for i in range(STEPS):
    # Record every record_interval steps
    if i % record_interval == 0:
        for hist, val in zip((time_hist, v_c_hist, v_1_hist, v_2_hist, v_3_hist,
                              i_l1_hist, i_l2_hist, i_l3_hist),
                             (i * DT, v_c, v_1, v_2, v_3, i_l1, i_l2, i_l3)):
            hist.append(val)
    
    # Calculate derivatives and do Euler update
    common_term = (VCC - v_3 + v_2 - v_c) / R
    v_c_next  = euler(v_c,  INV_C  * (common_term - i_e(v_c - v_2, -v_3)))
    v_1_next  = euler(v_1,  INV_C1 * (i_b(v_2 - v_1, -v_1) - i_l2 - i_l3))
    v_2_next  = euler(v_2,  INV_C2 * (i_e(v_c - v_2, -v_3) -
                                      i_e(v_2 - v_1, -v_1) -
                                      common_term - i_l1 + i_l3))
    v_3_next  = euler(v_3,  INV_C3 * (common_term - i_c(v_c - v_2, -v_3) - i_l3))
    i_l1_next = euler(i_l1, INV_L1 * v_2)
    i_l2_next = euler(i_l2, INV_L2 * v_1)
    # SHIFT = 0.15 as defined above
    i_l3_next = euler(i_l3, INV_L3 * (v_1 - v_2 + v_3 - SHIFT))

    # Update all state variables
    v_c, v_1, v_2, v_3 = v_c_next, v_1_next, v_2_next, v_3_next
    i_l1, i_l2, i_l3   = i_l1_next, i_l2_next, i_l3_next

delay = 150  # in units of "recorded steps" (not time steps)
X = np.array(v_c_hist[:-delay], dtype=np.float64)
Y = np.array(v_c_hist[delay:],  dtype=np.float64)

plt.figure(figsize=(8, 6))
plt.plot(X, Y, '.', markersize=1)
plt.xlabel("v_c(t)")
plt.ylabel(f"v_c(t + {delay * record_interval} steps)")
plt.title(f"Delayed Phase Plot of v_c (Delay = {delay * record_interval} steps)")
plt.grid(True)
plt.show()

recorded_steps = len(v_c_hist)
step_axis = np.arange(recorded_steps)

fig, axs = plt.subplots(7, 1, figsize=(10, 14), sharex=True)
axs[0].plot(step_axis, np.array(v_c_hist,  dtype=np.float64), color='tab:blue');   axs[0].set_ylabel('v_c');   axs[0].grid(True)
axs[1].plot(step_axis, np.array(v_1_hist,  dtype=np.float64), color='tab:orange'); axs[1].set_ylabel('v_1');   axs[1].grid(True)
axs[2].plot(step_axis, np.array(v_2_hist,  dtype=np.float64), color='tab:green');  axs[2].set_ylabel('v_2');   axs[2].grid(True)
axs[3].plot(step_axis, np.array(v_3_hist,  dtype=np.float64), color='tab:red');    axs[3].set_ylabel('v_3');   axs[3].grid(True)
axs[4].plot(step_axis, np.array(i_l1_hist, dtype=np.float64), color='tab:purple'); axs[4].set_ylabel('i_l1');  axs[4].grid(True)
axs[5].plot(step_axis, np.array(i_l2_hist, dtype=np.float64), color='tab:brown');  axs[5].set_ylabel('i_l2');  axs[5].grid(True)
axs[6].plot(step_axis, np.array(i_l3_hist, dtype=np.float64), color='tab:cyan');   axs[6].set_ylabel('i_l3')
axs[6].set_xlabel('Recorded Step Number'); axs[6].grid(True)

fig.suptitle('Simulation Signals vs Recorded Step Number', fontsize=16, y=0.94)
plt.tight_layout(rect=[0, 0, 1, 0.96])
plt.show()
