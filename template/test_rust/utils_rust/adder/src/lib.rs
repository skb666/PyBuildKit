use libc::c_int;

#[unsafe(no_mangle)]
pub extern "C" fn add(left: c_int, right: c_int) -> c_int {
    left + right
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() {
        let result = add(2, 2);
        assert_eq!(result, 4);
    }
}

