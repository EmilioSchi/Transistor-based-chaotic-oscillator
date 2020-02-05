//const DT:    f64 = 9.5367431640625e-07;
//fn euler(value: f64, function: f64) -> f64 {
//    value + function * DT
//}

const EXP_IEEE754:         u64 = 20; // 20 will be subtracted from exponent of IEEE754 number
const DT:                  f64 = 9.5367431640625e-07; // 1 / 2^20 WTF! const pow dont working
const EXPONENT_MASK64:     u64 = 0x7ff0000000000000;
const EXPONENT_MASK64_REV: u64 = 0x7FF;
const MANTISSA_WIDTH64:    u64 = 52;
fn fast_euler(value: f64, function: f64) -> f64 {
        let n_ieee754: u64 = function.to_bits();
        let exponent= ((n_ieee754 >> MANTISSA_WIDTH64) & EXPONENT_MASK64_REV).saturating_sub(EXP_IEEE754);
        value + f64::from_bits((n_ieee754 & (!EXPONENT_MASK64)) | ((exponent << MANTISSA_WIDTH64) & EXPONENT_MASK64))
}

// Nonlinear Function
const IS:    f64 = 10e-15;
const VT:    f64 = 0.0259;
const DROP:  f64 = 0.1;
const BETA_F: f64 = 145.76;
const BETA_R: f64 = 0.1001;

fn i_e(v_be: f64, v_bc: f64) -> f64 {
    let tmp = IS * (((v_be - DROP) / VT).exp() - ((v_bc - DROP) / VT).exp());
    match v_be > 0.0 {
        true  => (IS / BETA_F) * (((v_be - DROP) / VT).exp()) + tmp,
        false => tmp,
    }
}

fn i_c(v_be: f64, v_bc: f64) -> f64 {
    let tmp = IS * (((v_be - DROP) / VT).exp() - ((v_bc - DROP) / VT).exp());
    match v_bc > 0.0 {
        true => -(IS / BETA_R) * (((v_bc - DROP) / VT).exp()) + tmp,
        false => tmp,
    }
}

fn i_b(v_be: f64, v_bc: f64) -> f64 {
    match (v_be > 0.0, v_bc > 0.0) {
        (true, true) => (IS / BETA_F) * (((v_be - DROP) / VT).exp()) + (IS / BETA_R) * (((v_bc - DROP) / VT).exp()),
        (true, false) => (IS / BETA_F) * (((v_be - DROP) / VT).exp()),
        (false, true) => (IS / BETA_R) * (((v_bc - DROP) / VT).exp()),
        (false, false) => 0.0,
    }
}

// Component value
const VCC: f64 = 5.0;
const R: f64 = 226.0;
const L1: f64 = 150.0;
const L2: f64 = 68.0;
const L3: f64 = 15.0;
const C: f64 = 470e-6;
const C1: f64 = 30e-6;
const C2: f64 = 30e-6;
const C3: f64 = 1e-8;
// inversion
const INV_C: f64 = 1.0 / C;
const INV_C1: f64 = 1.0 / C1;
const INV_C2: f64 = 1.0 / C2;
const INV_C3: f64 = 1.0 / C3;
const INV_L1: f64 = 1.0 / L1;
const INV_L2: f64 = 1.0 / L2;
const INV_L3: f64 = 1.0 / L3;

fn main() {
    // duration
    let seconds: f64 = 150.0;
    // iteration
    let steps = (seconds / DT).round() as i64;

    let mut v_c: f64 = 0.76;
    let mut v_1: f64 = 50e-6;
    let mut v_2: f64 = 1e-8;
    let mut v_3: f64 = 10e-8;
    let mut i_l1: f64 = 2e-4;
    let mut i_l2: f64 = -2e-4;
    let mut i_l3: f64 = 2e-4;

    let mut v_c_next: f64;
    let mut v_1_next: f64;
    let mut v_2_next: f64;
    let mut v_3_next: f64;
    let mut i_l1_next: f64;
    let mut i_l2_next: f64;
    let mut i_l3_next: f64;

    for i in 1..steps {
        // Euler Method
        v_c_next  = fast_euler(v_c , INV_C  * (((VCC - v_3 + v_2 - v_c) / R) - i_e(v_c - v_2, -v_3)));
        v_1_next  = fast_euler(v_1 , INV_C1 * (i_b(v_2 - v_1, -v_1) - i_l2 - i_l3));
        v_2_next  = fast_euler(v_2 , INV_C2 * (i_e(v_c - v_2, -v_3) - i_e(v_2 - v_1, -v_1) - ((VCC - v_3 + v_2 - v_c) / R) - i_l1 + i_l3));
        v_3_next  = fast_euler(v_3 , INV_C3 * (((VCC - v_3 + v_2 - v_c) / R) - i_c(v_c - v_2, -v_3) - i_l3));
        i_l1_next = fast_euler(i_l1, INV_L1 * (v_2));
        i_l2_next = fast_euler(i_l2, INV_L2 * (v_1));
        i_l3_next = fast_euler(i_l3, INV_L3 * (v_1 - v_2 + v_3 - 0.15));
        // Update
        v_c = v_c_next;
        v_1 = v_1_next;
        v_2 = v_2_next;
        v_3 = v_3_next;
        i_l1 = i_l1_next;
        i_l2 = i_l2_next;
        i_l3 = i_l3_next;
        // Output
        if i % 1000 == 0 {
            println!("{};{};{};{};{};{};{}", v_c, v_1, v_2, v_3, i_l1, i_l2, i_l3);
        }
    }
}
