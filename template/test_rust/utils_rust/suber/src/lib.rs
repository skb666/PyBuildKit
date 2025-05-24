use libc::c_int;

#[unsafe(no_mangle)]
pub extern "C" fn sub(left: c_int, right: c_int) -> c_int {
    left - right
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() {
        let result = sub(6, 2);
        assert_eq!(result, 4);
    }
}
