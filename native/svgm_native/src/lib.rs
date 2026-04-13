#[rustler::nif]
fn optimize(svg: &str) -> Result<String, String> {
    match svgm_core::optimize(svg) {
        Ok(output) => Ok(output.data),
        Err(err) => Err(err.to_string()),
    }
}

rustler::init!("Elixir.SVGM.Native");
