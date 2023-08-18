#[macro_export]
macro_rules! test_fixture {
    ($cname:expr, $fname:expr) => {
        format!(
            "{}/src/{}/fixtures/{}",
            std::env::var("CARGO_MANIFEST_DIR").unwrap(),
            $cname,
            $fname
        )
    };
}
